#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Read the CSV file line by line and insert each row into the games table
tail -n +2 games.csv | while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
    # Insert the winner into the teams table if it doesn't exist
    $PSQL "INSERT INTO teams (name) SELECT '$winner' WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name = '$winner');"
    # Insert the opponent into the teams table if it doesn't exist
    $PSQL "INSERT INTO teams (name) SELECT '$opponent' WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name = '$opponent');"
    # Get the IDs of the winner and opponent
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")
    # Insert the game into the games table
    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
done
