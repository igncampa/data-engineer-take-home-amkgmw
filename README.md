# Take-Home Exercise: Data Engineering Challenge - Pokémon Tournament Edition

## Introduction

This repository contains the solution to the data engineering challenge `Pokémon Tournament Edition`. The ETL process is written in Python, with supplemental queries written in SQL and a SQLite database as the resulting output.

I recommend using a GUI tool like [SQLiteStudio](https://sqlitestudio.pl/) to import and explore the database.

## Description

This ETL script `main.py` processes tournament data by extracting the raw data in the `daily_data` directory, transforming it into the desired format, and loading it into a SQLite database `pokemon_tournament.db`.

The script uses a `config.ini` file for configuration parameters such as database connection settings, file paths, and other runtime options and produces a runtime log in the `logs` directory.

The script provides an optional argument `--add-views` to include solutions to the challenge as views in the database, while the raw sql queries can be found in the `/sql/queries` directory.
1. Solution to exercise `3.1` is created as `top_used_pokemons`.
2. Solution to exercise `3.2` is created as `matches_per_month`.
3. Solution to exercise `3.3` is created as `type_matchup_ocurrences`.
4. __Bonus:__ a view to track trainer performance and the tournament winner as `trainer_performance`.

## Installation

1. Clone this repository:
```bash
git clone http://genentech-lvijtd@git.codesubmit.io/genentech/data-engineer-take-home-amkgmw
cd data-engineer-take-home-amkgmw
```

2. Install the required libraries:
```bash
pip install -r requirements.txt
```

## Usage
Run the script:
```bash
python3 main.py [options]
```

Where available options are:
```bash
-h, --help   show the help message and exit
--add-views  Include exercise solutions as views in the database.
```

## Assumptions, thought process and decisions

* The first assumption is that all .csv files have the same columns, all contain headers, use the same encoding, delimiter and quoting characters. This assumption was validated after manipulating the data.
* General assumptions regarding the integrity of the data were made:
  - No battle was left hanging; meaning `planned` but neither `cancelled` nor `completed`.
  - Consistency throughout the dataset; in no instance does an `id` correspond to two or more different `name`.
  - Pokemon attributes are consistent trhoughout the match: it's not possible for a Pokemon to gain `hp`, `attack`, `defense` or `speed` in the middle of a battle.
- It makes sense to backfill pokemon stats where missing in rows with `battle_status` is `planned`. Given that some matches are cancelled, it is possible somebody would want to analyze all planned matches only.
- Backfilling the `trainer_winner_id` is unnecessary and might lead to consufsion. It is preferred to keep it only in completed matches.
- Case standarization in the `pokemon_type` columns is preferred to avoid case sensitivity-based errors when querying the data.

