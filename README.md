# Take-Home Exercise: Data Engineering Challenge - Pokémon Tournament Edition

### Objective
Welcome to the Pokémon Tournament Challenge! As a data engineer, your task is to help us host an epic Pokémon tournament by managing and analyzing battle data. You will work with daily battle logs, clean and normalize the data, and uncover insights about the best-performing Pokémon.
Your mission is to ensure our tournament runs smoothly and to crown the ultimate Pokémon champion based on your analysis. Get ready to dive into the world of Pokémon data and show off your data engineering skills!


### Data description
In the `daily_data` folder, you will find daily updates of the tournament battles. 
Each battle has a unique `battle id` and involves two trainers, each selecting one Pokémon for the battle.
Each time the battle status changes, a new entry with a `last_update_ts` timestamp is added to the daily update.
Battle Status:
- A battle is created with the status `Planned`.
- The status can then change to `In-Battle` and subsequently to `Completed`.
- Alternatively, a battle may be `Cancelled` after being `Planned`.

### Tasks

1. ETL Pipeline:
    - Use a Python script to load the data into a relational database (preferably SQLite).
    - Provide the SQL schema and any necessary scripts to create the database.
    - Organize the data to ensure it is well-structured, normalized and consistent.
    - Implement error handling and logging in your ETL pipeline.
2. Create a View
    - Write a SQL query that creates a view showing the most recent battle information for each battle ID.
    - Include in the view all information about the players and Pokémons.
    - Add a calculated column to the view that counts the wins and losses of each trainer as of the time of the last completed battle.
    #### Expected output schema:
    `battle_id| trainer1_id| pokemon1_id| trainer2_id| pokemon2_id| winner_trainer_id| battle_status| `
    `trainer1_name| trainer1_age| trainer1_city| trainer2_name| trainer2_age| trainer2_city| pokemon1_name|`
    `pokemon1_type1| pokemon1_type2| pokemon1_hp| pokemon1_attack| pokemon1_defense| pokemon1_speed| `
    `pokemon1_legendary| pokemon2_name| pokemon2_type1| pokemon2_type2| pokemon2_hp| pokemon2_attack| `
    `pokemon2_defense| pokemon2_speed| pokemon2_legendary| trainer1_wins| trainer2_wins| trainer1_losses`
    `| trainer2_losses| last_update_ts`
3. Analyze the data in the database
    - Write SQL queries to compute the following data:
        - 3.1 Which Pokémon is being most used in the tournament?
         #### Expected output schema: ` pokemon_name | pokemon_occurrences`
        - 3.2 How many battles took place each month?
         #### Expected output schema: ` month | number_of_battles`
        - 3.3 Bonus Question: Write a SQL query to find the occurrence of each type matchup (e.g., Grass vs Fire) and the win rate for each type matchup. Order the table by matchup count.
        Note: For cases of Pokémons with multiple types, all combination of types needs to be considered. For example, if Pokémon1 has types Fire and Grass, and Pokémon2 has types Water and Electric, this makes for 4 type matchups.
        
        #### Example expected output schema:  

        |  type1   | type2   | matchup_count | win_rate_type1 | win_rate_type2 |
        | :------:       | :-----:      | :-----------: | :------: |:------: |
        |  Grass         |  Fire        |      12       |    0.7   |0.3   |
        |  Grass         | Electric     |      10       |    0.5   |0.5   |


4. Documentation
    - Include a README file with instructions to run your solution.
    - Document any assumptions or decisions made during the exercise.

### Evaluation Criteria
- Correctness: Does the solution meet the specified requirements?
- Efficiency: Is the solution efficient in terms of time and space complexity?
- Code Quality: Is the code clean, well-organized, and readable?
- Completeness: Are all deliverables provided and functional?
- Documentation: Are the steps, assumptions, code and instructions clearly documented?

### CodeSubmit
Please organize, design and document your code as if it were going into production - then push your changes to the master branch. After you have pushed your code, you may submit the assignment on the assignment page.

All the best and happy coding,

The Roche Team
