--- Which age/gender groups run the longest distances? ---
--- mart_distance_by_age_gender 
--- This view shows average finish time and speed
--- grouped by age bracket and gender
--- avg_finish_time_hours: how long on average it took to finish the race (in hours)
--- avg_speed_kmh: average running speed in km/h
--- total_runners: number of athletes in that age/gender group for that event (used to assess statistical significance)


USE CATALOG marathos_cat;
USE SCHEMA gold;

CREATE OR REFRESH MATERIALIZED VIEW marathos_cat.gold.mart_distance_by_age_gender
COMMENT "Distance by age bracket and gender - gold layer" AS
SELECT
    e.unit_value AS distance_km,
    a.athlete_gender,
    CASE 
        WHEN f.age_at_event IS NULL THEN 'Unknown'
        WHEN f.age_at_event < 30 THEN 'Under 30'
        WHEN f.age_at_event < 40 THEN '30-39'
        WHEN f.age_at_event < 50 THEN '40-49'
        WHEN f.age_at_event < 60 THEN '50-59'
        WHEN f.age_at_event < 70 THEN '60-69'
        WHEN f.age_at_event < 80 THEN '70-79'
        WHEN f.age_at_event < 90 THEN '80-89'
        WHEN f.age_at_event < 100 THEN '90-99'
        ELSE '100+'
    END AS age_bracket,
    e.event_name,
    COUNT(*) AS total_runners,
    ROUND(AVG(f.finish_time_hours), 2) AS avg_finish_time_hours,
    ROUND(AVG(f.athlete_average_speed), 2) AS avg_speed_kmh
FROM fct_result f
LEFT JOIN dim_event e ON f.event_id = e.event_id
LEFT JOIN dim_athlete a ON f.athlete_id = a.athlete_id
WHERE e.event_type = 'distance'
GROUP BY a.athlete_gender, age_bracket, e.event_name, e.unit_value, e.unit_measure
ORDER BY e.unit_value DESC, total_runners DESC;
