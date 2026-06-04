--- Which countries produce the fastest and most active ultra marathon runners in distance races? 
--- avg_speed_kmh: average running speed in km/h (higher = faster runner)
--- total_races: total race participations from that country
--- total_athletes: distinct athletes from that country
--- Ordered by most active countries first (total_races DESC)

USE CATALOG marathos_cat;
USE SCHEMA gold;

CREATE OR REFRESH MATERIALIZED VIEW marathos_cat.gold.mart_distance_by_country
COMMENT "Average finish time and speed per country for distance races - gold layer" AS
SELECT 
    a.athlete_country,
    COUNT(*) AS total_races,
    COUNT(DISTINCT a.athlete_id) AS total_athletes,
    ROUND(AVG(f.athlete_average_speed), 2) AS avg_speed_kmh
FROM fct_result f
LEFT JOIN dim_event e ON f.event_id = e.event_id
LEFT JOIN dim_athlete a ON f.athlete_id = a.athlete_id
WHERE e.event_type = 'distance'
    AND f.athlete_id IS NOT NULL
    AND f.finish_time_hours IS NOT NULL
    AND a.athlete_country IS NOT NULL
GROUP BY a.athlete_country
ORDER BY total_races DESC