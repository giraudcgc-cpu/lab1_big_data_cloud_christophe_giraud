-- Here I was tempted to use "Club vs independant runners" but the "null" can either mean "no data recorded" or "no club".

USE CATALOG marathos_cat;
USE SCHEMA gold;

CREATE OR REFRESH MATERIALIZED VIEW marathos_cat.gold.mart_club_vs_norecordedclub_runners
COMMENT "Club vs no recorded club runners comparison - gold layer" AS
SELECT 
    CASE WHEN a.athlete_club IS NULL THEN 'No club recorded' ELSE 'Club Member' END AS runner_type,
    a.athlete_gender,
    COUNT(DISTINCT a.athlete_id) AS total_athletes,
    COUNT(*) AS total_races,
    AVG(f.athlete_performance_value) AS avg_performance,
    AVG(f.athlete_average_speed) AS avg_speed,
    AVG(a.athlete_year_of_birth) AS avg_birth_year
FROM fct_result f
LEFT JOIN dim_athlete a ON f.athlete_id = a.athlete_id
LEFT JOIN dim_event e ON f.event_id = e.event_id
GROUP BY runner_type, a.athlete_gender