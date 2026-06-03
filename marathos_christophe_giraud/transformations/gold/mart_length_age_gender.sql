USE CATALOG marathos_cat;
USE SCHEMA gold;

CREATE OR REFRESH MATERIALIZED VIEW marathos_cat.gold.mart_length_age_gender 
COMMENT "Length of time by age bracket and gender - gold layer" AS
SELECT 
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
    e.unit_value,
    COUNT(*) AS total_runners,
    AVG(f.athlete_performance_value) AS avg_performance,
    AVG(f.athlete_average_speed) AS avg_speed
FROM fct_result f
LEFT JOIN dim_event e ON f.event_id = e.event_id
LEFT JOIN dim_athlete a ON f.athlete_id = a.athlete_id
WHERE e.event_type = 'duration'
GROUP BY a.athlete_gender, age_bracket, e.event_name, e.unit_value





