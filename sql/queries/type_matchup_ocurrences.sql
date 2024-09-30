/*
Find the occurrence of each type matchup and the win rate for each.
All combinations of types needs to be considered.
*/

WITH type_combinations AS (
    -- pokemon1_type1 vs pokemon2_type1
    SELECT
        CASE WHEN winner_trainer_id = trainer1_id THEN 1 ELSE 0 END AS pokemon1_win,
        CASE WHEN winner_trainer_id = trainer2_id THEN 1 ELSE 0 END AS pokemon2_win,
        -- Ensures alphabetical ordering for all matchup types
        CASE WHEN pokemon1_type1 < pokemon2_type1 THEN pokemon1_type1 ELSE pokemon2_type1 END AS type1,
        CASE WHEN pokemon1_type1 < pokemon2_type1 THEN pokemon2_type1 ELSE pokemon1_type1 END AS type2
    FROM
        fact_tournament_battles
    WHERE
        battle_status = 'Completed'

    UNION ALL

    -- pokemon1_type1 vs pokemon2_type2
    SELECT
        CASE WHEN winner_trainer_id = trainer1_id THEN 1 ELSE 0 END AS pokemon1_win,
        CASE WHEN winner_trainer_id = trainer2_id THEN 1 ELSE 0 END AS pokemon2_win,
        -- Ensures alphabetical ordering for all matchup types
        CASE WHEN pokemon1_type1 < pokemon2_type2 THEN pokemon1_type1 ELSE pokemon2_type2 END AS type1,
        CASE WHEN pokemon1_type1 < pokemon2_type2 THEN pokemon2_type2 ELSE pokemon1_type1 END AS type2
    FROM
        fact_tournament_battles
    WHERE
        battle_status = 'Completed'

    UNION ALL

    -- pokemon1_type2 vs pokemon2_type1
    SELECT
        CASE WHEN winner_trainer_id = trainer1_id THEN 1 ELSE 0 END AS pokemon1_win,
        CASE WHEN winner_trainer_id = trainer2_id THEN 1 ELSE 0 END AS pokemon2_win,
        -- Ensures alphabetical ordering for all matchup types
        CASE WHEN pokemon1_type2 < pokemon2_type1 THEN pokemon1_type2 ELSE pokemon2_type1 END AS type1,
        CASE WHEN pokemon1_type2 < pokemon2_type1 THEN pokemon2_type1 ELSE pokemon1_type2 END AS type2
    FROM
        fact_tournament_battles
    WHERE
        battle_status = 'Completed'

    UNION ALL

    -- pokemon1_type2 vs pokemon2_type2
    SELECT
        CASE WHEN winner_trainer_id = trainer1_id THEN 1 ELSE 0 END AS pokemon1_win,
        CASE WHEN winner_trainer_id = trainer2_id THEN 1 ELSE 0 END AS pokemon2_win,
        -- Ensures alphabetical ordering for all matchup types
        CASE WHEN pokemon1_type2 < pokemon2_type2 THEN pokemon1_type2 ELSE pokemon2_type2 END AS type1,
        CASE WHEN pokemon1_type2 < pokemon2_type2 THEN pokemon2_type2 ELSE pokemon1_type2 END AS type2
    FROM
        fact_tournament_battles
    WHERE
        battle_status = 'Completed'
)
-- Aggregate values and calculate win rates
SELECT
    type1,
    type2,
    COUNT(*) AS matchup_count,
    ROUND(SUM(pokemon1_win) * 1.0 / COUNT(*), 1) AS win_rate_type1,
    ROUND(SUM(pokemon2_win) * 1.0 / COUNT(*), 1) AS win_rate_type2
FROM
    type_combinations
WHERE
    type1 IS NOT NULL
    AND type2 IS NOT NULL
GROUP BY
    type1, type2
ORDER BY
    matchup_count DESC;
