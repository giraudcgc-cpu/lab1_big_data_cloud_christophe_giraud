CREATE OR REFRESH MATERIALIZED VIEW marathos_cat.gold.dim_athlete
COMMENT "Dimension table - gold layer - Marathos" AS
SELECT
    athlete_id,
    MAX_BY(athlete_gender, year_of_event) AS athlete_gender,
    MAX_BY(athlete_year_of_birth, year_of_event) AS athlete_year_of_birth,
    MAX_BY(athlete_country, year_of_event) AS athlete_country,
    MAX_BY(athlete_club, year_of_event) AS athlete_club,
    MAX_BY(athlete_age_category, year_of_event) AS athlete_age_category
FROM marathos_cat.silver.marathos_obt
GROUP BY athlete_id;