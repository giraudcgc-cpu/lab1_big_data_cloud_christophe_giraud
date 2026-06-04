from pyspark import pipelines as dp
from pyspark.sql.functions import col, trim, regexp_replace, when, regexp_extract, upper, sha2
from pyspark.sql.functions import round as spark_round, try_to_date
from utils.utils import rename_columns_to_snake_case

@dp.table(name="marathos_cat.silver.marathos_obt",
    comment="Cleaned marathos data",
    table_properties={
        "delta.columnMapping.mode": "name",
        "delta.minReaderVersion": "2",
        "delta.minWriterVersion": "5"
    }
)

def cleaned_marathos():
    df = rename_columns_to_snake_case(spark.sql("SELECT * FROM STREAM marathos_cat.bronze.raw_marathos"))

    return (
# --- trim all strings ---
# --- and renaming the column ---
        df
        .withColumnRenamed("event_distance_or_length", "event_distance_or_duration")
        .withColumn("event_name", trim(col("event_name")))
        .withColumn("athlete_club", trim(col("athlete_club")))
        .withColumn("athlete_country", trim(col("athlete_country")))
        .withColumn("athlete_gender", trim(col("athlete_gender")))
        .withColumn("athlete_age_category", trim(col("athlete_age_category")))
        .withColumn("event_distance_or_duration", trim(col("event_distance_or_duration")))
        .withColumn("athlete_performance", trim(col("athlete_performance")))
   
# --- year_of_event ---
        .filter((col('year_of_event') >= 1896) & (col('year_of_event') <= 2022))

# --- event_dates ---
        .withColumn("event_dates", try_to_date(col("event_dates"), "dd.MM.yyyy"))

# --- event_name ---
        .withColumn("event_name", regexp_replace(col("event_name"), r'[\"<>#\+]', ''))

# --- remove d (days) and Etappen ---
        .filter(~col("event_distance_or_duration").rlike(r"^\d+\.?\d*d"))
        .filter(~col("event_distance_or_duration").contains("Etappen"))

# --- unit_measure ---
        .withColumn("unit_measure", regexp_extract(col("event_distance_or_duration"), r"[a-zA-Z]+", 0))
        .filter(~col("unit_measure").isin(["None", "m", "x", ""]))
        .withColumn("unit_measure",
            when(col("unit_measure").isin(["km", "Km", "k", "K"]), "km")
            .when(col("unit_measure").isin(["mi", "Miles", "miles", "Mile", "mile"]), "mi")
            .when(col("unit_measure") == "h", "h")
            .otherwise(col("unit_measure"))
        )

# --- event_type ---
        .withColumn("event_type",
            when(col("unit_measure") == "km", "distance")
            .when(col("unit_measure") == "h", "duration")
            .otherwise(None)
        )

# --- unit_value ---
        .withColumn("unit_value",
            spark_round(
                when(col("unit_measure") == "mi",
                    regexp_extract(col("event_distance_or_duration"), r"(\d+\.?\d*)", 1).cast("double") * 1.60934)
                .otherwise(
                    regexp_extract(col("event_distance_or_duration"), r"(\d+\.?\d*)", 1).cast("double")
                ),
                2
            )
        )
        .withColumn("unit_measure", when(col("unit_measure") == "mi", "km").otherwise(col("unit_measure")))

# --- performance_unit ---
        .withColumn("performance_unit", regexp_extract(col("athlete_performance"), r"[a-zA-Z]+", 0))

# --- I had athlete_performance_value which could be time or distance and was not only misleading but causing problems, so I split it into 2 ---
# --- finish_time_hours (for distance events only) ---
        .withColumn("finish_time_hours",
            when(col("performance_unit") == "h",
                spark_round(
                    regexp_extract(col("athlete_performance"), r"(\d+):(\d+):(\d+)", 1).cast("double") +
                    regexp_extract(col("athlete_performance"), r"(\d+):(\d+):(\d+)", 2).cast("double") / 60 +
                    regexp_extract(col("athlete_performance"), r"(\d+):(\d+):(\d+)", 3).cast("double") / 3600,
                    2
                )
            ).otherwise(None)
        )

# --- run_distance_km (for duration events only) ---
        .withColumn("run_distance_km",
            when(col("performance_unit") != "h",
                spark_round(
                    regexp_extract(col("athlete_performance"), r"(\d+\.?\d*)", 1).cast("double"),
                    2
                )
            ).otherwise(None)
        )

# --- athlete_average_speed ---
        .withColumn("athlete_average_speed",
            spark_round(
                when(col("athlete_average_speed").rlike(r"^\d+\.?\d*$"),
                     col("athlete_average_speed").cast("double"))
                .otherwise(None),
                1
            )
        )
        .filter(
            col("athlete_average_speed").isNull() |
            ((col("athlete_average_speed") > 0) & (col("athlete_average_speed") <= 21))
        )

# --- athlete_club ---
        .withColumn("athlete_club",
            trim(regexp_replace(col("athlete_club"), r'^[^a-zA-Z0-9\u4e00-\u9fff]+|[^a-zA-Z0-9\u4e00-\u9fff]+$', ''))
        )
        .withColumn("athlete_club", when(col("athlete_club") == '', None).otherwise(col("athlete_club")))

# --- athlete_country ---
        .withColumn("athlete_country", upper(col("athlete_country")))

# --- athlete_year_of_birth ---
        .withColumn("athlete_year_of_birth", col("athlete_year_of_birth").cast("int"))
        .filter(
            col("athlete_year_of_birth").isNull() |
            ((col("athlete_year_of_birth") >= 1922) & (col("athlete_year_of_birth") <= 2004))
        )
        .withColumn("age_at_event", col("year_of_event") - col("athlete_year_of_birth"))

# --- event_number_of_finishers ---
        .filter(col("event_number_of_finishers") > 0)

# --- athlete_gender ---
        .filter(col("athlete_gender").isin(["M", "F"]))

# --- athlete_id ---
        .filter(col("athlete_id") > 0)

# --- athlete_age_category ---
        .withColumn("athlete_age_category",
            when(col("athlete_age_category").startswith("W"),
                 regexp_replace(col("athlete_age_category"), "^W", "F"))
            .otherwise(col("athlete_age_category"))
        )


# --- deduplication ---
        .dropDuplicates(["athlete_id", "event_name", "event_dates", "event_distance_or_duration"])


# These below were missing when I tried to run the dimensional model
# --- event_id ---
        .withColumn("event_id", sha2(col("event_name"), 256))

# --- date_id ---
        .withColumn("date_id", sha2(col("year_of_event").cast("string"), 256))
    )
