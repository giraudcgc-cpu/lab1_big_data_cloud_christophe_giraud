CREATE OR REFRESH MATERIALIZED VIEW marathos_cat.gold.fct_result
COMMENT "Fact table - gold layer - Marathos" AS
SELECT
    athlete_id,
    event_id,
    date_id,
    finish_time_hours,
    run_distance_km,
    athlete_average_speed,
    event_number_of_finishers,
    event_dates,
    age_at_event  -- wanted to add it to dim_athlete but not fixed as changes each year/race
FROM marathos_cat.silver.marathos_obt;