import os
import glob
import sqlite3
import logging
import argparse
import configparser
import pandas as pd


def setup_logging(log_file, log_level='INFO'):
    """
    Sets up logging.
    """

    log_folder = os.path.dirname(log_file)
    if not os.path.exists(log_folder):
        os.makedirs(log_folder)

    logging.basicConfig(
        filename=log_file,
        level=getattr(logging, log_level, logging.INFO),
        format='%(asctime)s - %(levelname)s - %(message)s',
    )


def load_config(config_path='config.ini'):
    """
    Loads configuration file.
    """
    config = configparser.ConfigParser()

    if not os.path.exists(config_path):
        logging.error(f"Configuration file {config_path} not found.")
        sys.exit(1)

    config.read(config_path)
    return config


def check_integrity(df):
    """
    Performs critical integrity checks.
    Failure denotes corrupted data.
    1) Checks for NULL battle_id, trainer1_id or trainer2_id.
    2) Checks for COMPLETED matches without winner_trainer_id.

    Returns a boolean response.
    """
    integrity_passed = True

    # 1) Check for NULL battle_id, trainer1_id, or trainer2_id
    null_battle_ids = df['battle_id'].isnull().any()
    null_trainer1_ids = df['trainer1_id'].isnull().any()
    null_trainer2_ids = df['trainer2_id'].isnull().any()

    if null_battle_ids or null_trainer1_ids or null_trainer2_ids:
        logging.error("Null values found in battle_id, trainer1_id, or trainer2_id.")
        integrity_passed = False

    # 2) Check for COMPLETED matches without winner_trainer_id
    completed_without_winner = df[
        (df['battle_status'] == 'Completed') & (df['winner_trainer_id'].isnull())
    ]

    if not completed_without_winner.empty:
        logging.error("Completed matches without winner_trainer_id found.")
        integrity_passed = False

    return integrity_passed


def extract(file_dir):
    """
    Reads through all .csv files in the directory and merges them.

    Returns a single DataFrame containing all merged data.
    """
    try:
        dfs = []
        csv_files = glob.glob(os.path.join(file_dir, "*.csv"))
        for _file in csv_files:
            df = pd.read_csv(_file)
            dfs.append(df)

        df = pd.concat(dfs, ignore_index=True)
        logging.info("Data extraction completed successfully.")
        return df

    except Exception as e:
        logging.error(f"Error during data extraction: {e}")
        raise


def transform(df):
    """
    1) Removes duplicate rows.
    2) Backfills missing pokemon stats.
    3) Splits pokemon types into separate columns.

    Returns the transformed DataFrame
    """
    try:
        # 1) Remove duplicate rows
        df = df.drop_duplicates()

        # 2) Backfill missing pokemon stats
        df = df.sort_values(by=['battle_id', 'last_update_ts'])
        poke1_cols = ['pokemon1_hp', 'pokemon1_attack', 'pokemon1_defense', 'pokemon1_speed']
        poke2_cols = ['pokemon2_hp', 'pokemon2_attack', 'pokemon2_defense', 'pokemon2_speed']
        df[poke1_cols] = df.groupby('battle_id')[poke1_cols].bfill()
        df[poke2_cols] = df.groupby('battle_id')[poke2_cols].bfill()

        # 3) Split pokemon types into separate columns
        df[['pokemon1_type1', 'pokemon1_type2']] = df['pokemon1_types'].str.split(',', expand=True)
        df[['pokemon2_type1', 'pokemon2_type2']] = df['pokemon2_types'].str.split(',', expand=True)
        df = df.drop(['pokemon1_types', 'pokemon2_types'], axis=1)

        df['pokemon1_type1'] = df['pokemon1_type1'].str.capitalize()
        df['pokemon1_type2'] = df['pokemon1_type2'].str.capitalize()
        df['pokemon2_type1'] = df['pokemon2_type1'].str.capitalize()
        df['pokemon2_type2'] = df['pokemon2_type2'].str.capitalize()

        logging.info("Data transformation completed successfully.")
        return df

    except Exception as e:
        logging.error(f"Error during data transformation: {e}")
        raise


def load(df, conn):
    """
    Loads the data into the database.
    """
    try:
        df.to_sql('fact_tournament_battles', conn, if_exists='append', index=False)
        logging.info("Data loaded successfully into fact_tournament_battles table.")
    except Exception as e:
        logging.error(f"Failed to load data into the database: {e}")
        raise


def parse_arguments():
    """
    Parses command-line arguments.

    Returns:
    - args: Parsed arguments.
    """
    parser = argparse.ArgumentParser(description='ETL script for processing tournament data.')
    parser.add_argument('--create-additional-views', nargs='*', metavar=('VIEW_NAME', 'SCRIPT_PATH'),
                        help='Create additional views by specifying view names and their corresponding SQL script paths.')

    return parser.parse_args()


def main():
    """
    Main function.
    """
    # Load configuration
    config = load_config()

    # Parse command-line arguments
    parser = argparse.ArgumentParser(description='ETL script for processing tournament data.')
    parser.add_argument('--add-views', action='store_true', help='Include exercise solutions as views in the database.')
    args = parser.parse_args()

    # Setup logging
    log_file = config['LOGGING'].get('LOG_FILE', 'logs/etl.log')
    log_level = config['LOGGING'].get('LOG_LEVEL', 'INFO')
    setup_logging(log_file, log_level)
    logging.info("ETL process started.")

    # Create the SQLite DB connection
    conn = sqlite3.connect(config['DATABASE']['DB_PATH'])
    cursor = conn.cursor()

    # Create the Tournament Battles facts table
    fact_tournament_battles_schema_path = config['DATABASE']['FACT_TOURNAMENT_BATTLES_SCHEMA']
    with open(fact_tournament_battles_schema_path, 'r') as file:
        ddl = file.read()

    # Execute the schema
    cursor.executescript(ddl)
    conn.commit()

    try:
        # Extract
        file_dir = config['FILES']['FILE_DIRECTORY']
        df = extract(file_dir)

        # Transform
        df = transform(df)

        # Integrity check
        if not check_integrity(df):
            logging.error("Data integrity checks failed.")
            sys.exit(1)

        # Load
        load(df, conn)

        # Exercise 2: Create the cumulative battle stats view
        with open(config['DATABASE']['CUMULATIVE_BATTLE_STATS_VIEW'], 'r') as file:
            ddl = file.read()

        cursor.executescript(ddl)
        conn.commit()
        logging.info("Cumulative battle stats view created successfully.")

        # Exercise 3: Add the SQL exercises as views
        if args.add_views:
            queries = {
                config['DATABASE']['TOP_USED_POKEMONS']: 'top_used_pokemons',
                config['DATABASE']['MATCHES_PER_MONTH']: 'matches_per_month',
                config['DATABASE']['TYPE_MATCHUP_OCURRENCES']: 'type_matchup_ocurrences',
                config['DATABASE']['TRAINER_PERFORMANCE']: 'trainer_performance',
            }

            # Iterate through the dictionary
            for file_path, view_name in queries.items():
                # Check if the SQL script file exists
                if not os.path.exists(file_path):
                    logging.error(f"SQL script for {view_name} not found.")
                    continue

                # Read the SQL query from the file
                with open(file_path, 'r') as file:
                    ddl = file.read()

                # Prepend to the script
                ddl = f"DROP VIEW IF EXISTS {view_name}; CREATE VIEW {view_name} AS {ddl}"
                cursor.executescript(ddl)

            conn.commit()
            logging.info("Additional views created successfully.")

    except Exception as e:
        logging.error(f"Error during ETL process: {e}")
        raise

    finally:
        conn.close()


if __name__ == "__main__":
    main()
