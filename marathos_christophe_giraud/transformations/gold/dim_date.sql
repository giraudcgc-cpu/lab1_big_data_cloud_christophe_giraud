CREATE OR REFRESH MATERIALIZED VIEW marathos_cat.gold.dim_date
COMMENT "Dimension table - gold layer - Marathos" AS
SELECT DISTINCT
    date_id,
    year_of_event
FROM marathos_cat.silver.marathos_obt;