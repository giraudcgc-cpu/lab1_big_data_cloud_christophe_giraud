--- Who are the top 5 athletes per duration event based on run distance?
--- run_distance_km: distance covered by the athlete before time ran out
--- avg_speed_kmh: individual athlete's average speed
--- rank: 1 = furthest distance covered in that event

USE CATALOG marathos_cat;
USE SCHEMA gold;

CREATE OR REFRESH MATERIALIZED VIEW marathos_cat.gold.mart_top5_duration_event
COMMENT "Top 5 athletes per duration - gold layer" AS
SELECT 
    e.event_name,
    a.athlete_id,
    a.athlete_gender,
    a.athlete_country,
    f.run_distance_km AS run_distance_km,
    f.athlete_average_speed AS avg_speed_kmh,
    RANK() OVER (PARTITION BY e.event_name ORDER BY f.run_distance_km DESC) AS rank
FROM fct_result f
LEFT JOIN dim_event e ON f.event_id = e.event_id
LEFT JOIN dim_athlete a ON f.athlete_id = a.athlete_id
WHERE e.event_type = 'duration'
QUALIFY rank <= 5