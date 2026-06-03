CREATE OR REFRESH MATERIALIZED VIEW marathos_cat.gold.dim_event 
COMMENT "Dimension table - gold layer - Marathos" AS
SELECT
    event_id,
    MAX_BY(event_name, year_of_event) AS event_name,
    MAX_BY(event_type, year_of_event) AS event_type,
    MAX_BY(unit_measure, year_of_event) AS unit_measure,
    MAX_BY(unit_value, year_of_event) AS unit_value,
    MAX_BY(event_distance_or_duration, year_of_event) AS event_distance_or_duration
FROM marathos_cat.silver.marathos_obt
GROUP BY event_id;