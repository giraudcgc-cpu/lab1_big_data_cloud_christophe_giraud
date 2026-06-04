--- Do club members perform better than non-members?
--- mart_club_vs_norecordedclub_runners 
--- avg_performance_value: time in hours (distance races) or km covered (duration races) - mixed
--- avg_speed_kmh is the universal metric (valid for both distance and duration events)

USE CATALOG marathos_cat;
USE SCHEMA gold;

CREATE OR REFRESH MATERIALIZED VIEW marathos_cat.gold.mart_club_vs_norecordedclub_runners
COMMENT "Club vs no recorded club runners comparison - gold layer" AS
SELECT 
    CASE WHEN a.athlete_club IS NULL THEN 'No club recorded' ELSE 'Club Member' END AS runner_type,
    a.athlete_gender,
    COUNT(DISTINCT a.athlete_id) AS total_athletes,
    COUNT(*) AS total_races,
    ROUND(AVG(f.athlete_average_speed), 2) AS avg_speed_kmh,
    CAST(AVG(a.athlete_year_of_birth) AS INT) AS avg_birth_year
FROM fct_result f
LEFT JOIN dim_athlete a ON f.athlete_id = a.athlete_id
LEFT JOIN dim_event e ON f.event_id = e.event_id
GROUP BY runner_type, a.athlete_gender