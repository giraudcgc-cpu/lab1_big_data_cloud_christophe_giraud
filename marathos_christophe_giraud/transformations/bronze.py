
from pyspark import pipelines as dp

# --- Reading csv file from "raw" volume
VOLUME_PATH = "/Volumes/marathos_cat/default/raw"

schema = (
    spark.read
    .format("csv")
    .options(header=True, inferSchema=True)
    .load(VOLUME_PATH)
    .schema
)

@dp.table(
    name="marathos_cat.bronze.raw_races",
    comment="Raw marathos data",
    table_properties={
        "delta.columnMapping.mode": "name",
        "delta.minReaderVersion": "2",
        "delta.minWriterVersion": "5"
    }
)

# --- Streaming in continue ---
def raw_races():
    return (spark.readStream
            .format("csv")
            .options(header=True, encoding="utf-8")
            .schema(schema)
            .load(VOLUME_PATH)
)