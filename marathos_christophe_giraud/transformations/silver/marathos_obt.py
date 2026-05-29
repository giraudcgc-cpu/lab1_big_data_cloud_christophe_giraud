from pyspark import pipelines as dp 
from utils.utils import rename_columns_to_snake_case


@dp.table(
    name="marathos_cat.silver.marathos_obt",
    comment="Cleaned marathos data",
    table_properties={
        "delta.columnMapping.mode": "name",
        "delta.minReaderVersion": "2",
        "delta.minWriterVersion": "5"
    }
)

def cleaned_marathos():
    df = spark.sql("FROM STREAM marathos_cat.bronze.raw_marathos")
    df_cleaned = rename_columns_to_snake_case(df)

    return #to finish
  