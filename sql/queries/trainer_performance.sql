/*
Datermine the tournament winner by ranking trainers by their wins.
Since every battle has a trainer1 and a trainer2, we need to normalize the dataset.
*/

WITH battle_results AS (
    -- Normalize the dataset to have trainer1 and trainer2 in a single column
    SELECT 
        trainer1_id AS trainer_id,
        trainer1_name AS trainer_name,
        pokemon1_id AS pokemon_id,
        pokemon1_name AS pokemon_name,
        CASE WHEN winner_trainer_id = trainer1_id THEN 1 ELSE 0 END AS win,
        CASE WHEN winner_trainer_id != trainer1_id THEN 1 ELSE 0 END AS loss
    FROM
        fact_tournament_battles
    WHERE
        battle_status = 'Completed'

    UNION ALL

    SELECT 
        trainer2_id AS trainer_id,
        trainer2_name AS trainer_name,
        pokemon2_id AS pokemon_id,
        pokemon2_name AS pokemon_name,
        CASE WHEN winner_trainer_id = trainer2_id THEN 1 ELSE 0 END AS win,
        CASE WHEN winner_trainer_id != trainer2_id THEN 1 ELSE 0 END AS loss
    FROM
        fact_tournament_battles
    WHERE
        battle_status = 'Completed'
),
-- Gather the sum of wins and losses per trainer
trainer_stats AS (
    SELECT 
        trainer_id,
        trainer_name,
        SUM(win) AS wins,
        SUM(loss) AS losses,
        COUNT(*) AS total_battles
    FROM
        battle_results
    GROUP BY
        trainer_id, trainer_name
),
-- Gather each trainers top-performing pokemon
top_pokemon AS (
    SELECT 
        trainer_id,
        pokemon_name,
        wins,
        ROW_NUMBER() OVER (PARTITION BY trainer_id ORDER BY wins DESC) AS rank
    FROM (
        SELECT 
            trainer_id,
            pokemon_name,
            SUM(win) AS wins
        FROM
            battle_results
        GROUP BY
            trainer_id, pokemon_name
    ) pokemon_wins
)
SELECT 
    ts.trainer_id,
    ts.trainer_name,
    ts.wins,
    ts.losses,
    ts.total_battles,
    tp.pokemon_name AS top_performing_pokemon
FROM
    trainer_stats ts
JOIN
    top_pokemon tp ON ts.trainer_id = tp.trainer_id AND tp.rank = 1
ORDER BY
    ts.wins DESC, ts.total_battles DESC;
