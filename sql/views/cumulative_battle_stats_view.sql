CREATE VIEW IF NOT EXISTS cumulative_battle_stats AS
    WITH all_battle_stats AS (
        -- Normalize into single winner and loser columns
        -- Trainer1 battles
        SELECT
            battle_id,
            last_update_ts,
            trainer1_id AS trainer_id,
            ROW_NUMBER() OVER (PARTITION BY trainer1_id ORDER BY last_update_ts) AS battle_seq,
            CASE WHEN winner_trainer_id = trainer1_id THEN 1 ELSE 0 END AS won,
            CASE WHEN winner_trainer_id <> trainer1_id THEN 1 ELSE 0 END AS lost
        FROM
            fact_tournament_battles
        WHERE
            battle_status = 'Completed'

        UNION ALL

        -- Trainer2 battles
        SELECT
            battle_id,
            last_update_ts,
            trainer2_id AS trainer_id,
            ROW_NUMBER() OVER (PARTITION BY trainer2_id ORDER BY last_update_ts) AS battle_seq,
            CASE WHEN winner_trainer_id = trainer2_id THEN 1 ELSE 0 END AS won,
            CASE WHEN winner_trainer_id <> trainer2_id THEN 1 ELSE 0 END AS lost
        FROM
            fact_tournament_battles
        WHERE
            battle_status = 'Completed'
    ),
    cumulative_stats AS (
        SELECT
            trainer_id,
            battle_id,
            last_update_ts,
            battle_seq,
            SUM(won) OVER (PARTITION BY trainer_id ORDER BY last_update_ts ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_wins,
            SUM(lost) OVER (PARTITION BY trainer_id ORDER BY last_update_ts ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_losses
        FROM
            all_battle_stats
    )
    SELECT
        tm.battle_id,
        tm.trainer1_id,
        tm.pokemon1_id,
        tm.trainer2_id,
        tm.pokemon2_id,
        tm.winner_trainer_id,
        tm.battle_status,
        tm.trainer1_name,
        tm.trainer1_age,
        tm.trainer1_city,
        tm.trainer2_name,
        tm.trainer2_age,
        tm.trainer2_city,
        tm.pokemon1_name,
        tm.pokemon1_type1,
        tm.pokemon1_type2,
        tm.pokemon1_hp,
        tm.pokemon1_attack,
        tm.pokemon1_defense,
        tm.pokemon1_speed,
        tm.pokemon1_legendary,
        tm.pokemon2_name,
        tm.pokemon2_type1,
        tm.pokemon2_type2,
        tm.pokemon2_hp,
        tm.pokemon2_attack,
        tm.pokemon2_defense,
        tm.pokemon2_speed,
        tm.pokemon2_legendary,
        t1.cumulative_wins AS trainer1_wins,
        t2.cumulative_wins AS trainer2_wins,
        t1.cumulative_losses AS trainer1_losses,
        t2.cumulative_losses AS trainer2_losses,
        tm.last_update_ts
    FROM
        fact_tournament_battles tm
    LEFT JOIN
        cumulative_stats t1 ON tm.battle_id = t1.battle_id AND tm.trainer1_id = t1.trainer_id
    LEFT JOIN
        cumulative_stats t2 ON tm.battle_id = t2.battle_id AND tm.trainer2_id = t2.trainer_id
    WHERE (tm.battle_id, tm.last_update_ts) IN (
        SELECT
            battle_id,
            MAX(last_update_ts)
        FROM
            fact_tournament_battles
        GROUP BY
            battle_id
    );
