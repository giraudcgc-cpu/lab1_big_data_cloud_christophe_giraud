
from pyspark import pipelines as dp

# --- Reading csv file from "raw" volume
BASE_DIR = "/Volumes/marathos_cat/default/raw"

schema = (
    spark.read.format("csv")
    .options(header=True, inferSchema=True)
    .load(f"{BASE_DIR}/TWO_CENTURIES_OF_UM_RACES.csv")
    .schema
)

@dp.table(
    name="marathos_cat.bronze.raw_marathos",
    comment="Raw marathos data",
    table_properties={
        "delta.columnMapping.mode": "name",
        "delta.minReaderVersion": "2",
        "delta.minWriterVersion": "5"
    }
)

# --- Streaming in continue ---
def raw_marathos():
    return (spark.readStream.format("csv")
            .options(header=True, encoding="utf-8")
            .schema(schema)
            .load(f"{BASE_DIR}")
)
