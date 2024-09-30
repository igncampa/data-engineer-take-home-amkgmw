/*
Calculate which Pokémon is being most used in the tournament.
Since every battle has a pokemon1 and a pokemon2, we need to normalize the dataset.
*/

WITH unique_matches AS (
    SELECT DISTINCT
        battle_id,
        pokemon1_name,
        pokemon2_name
    FROM
        fact_tournament_battles
)
SELECT
    pokemon_name,
    COUNT(*) AS pokemon_occurrences
FROM (
    SELECT
        pokemon1_name AS pokemon_name
    FROM
        unique_matches
    UNION ALL
    SELECT
        pokemon2_name AS pokemon_name
    FROM
        unique_matches
) AS combined_pokemon
GROUP BY
    pokemon_name
ORDER BY
    pokemon_occurrences DESC
LIMIT 1;
