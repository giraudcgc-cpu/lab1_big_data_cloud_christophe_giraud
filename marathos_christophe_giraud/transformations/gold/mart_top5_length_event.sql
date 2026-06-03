USE CATALOG marathos_cat;
USE SCHEMA gold;

CREATE OR REFRESH MATERIALIZED VIEW marathos_cat.gold.mart_top5_length_event
COMMENT "Top 5 athletes per length of time - gold layer" AS
SELECT 
    e.event_name,
    a.athlete_id,
    a.athlete_gender,
    a.athlete_country,
    f.athlete_performance_value,
    f.athlete_average_speed,
    RANK() OVER (PARTITION BY e.event_name ORDER BY f.athlete_performance_value DESC) AS rank
FROM fct_result f
LEFT JOIN dim_event e ON f.event_id = e.event_id
LEFT JOIN dim_athlete a ON f.athlete_id = a.athlete_id
WHERE e.event_type = 'duration'
QUALIFY rank <= 5