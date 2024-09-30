/*
Calculate how many battles took place each month.
Assuming the question refers to completed battles only.
*/

WITH unique_matches AS (
    SELECT DISTINCT
        battle_id,
        strftime('%Y', last_update_ts) AS year,
        strftime('%m', last_update_ts) AS month
    FROM
        fact_tournament_battles
    WHERE
        battle_status = 'Completed'
)
SELECT
    month,
    COUNT(DISTINCT battle_id) AS number_of_battles
FROM
    unique_matches
GROUP BY
    year,
    month
ORDER BY
    year,
    month;
