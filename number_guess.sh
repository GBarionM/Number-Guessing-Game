#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$((RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id = $USER_ID")

  BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games WHERE user_id = $USER_ID")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

TRIES=1

until [[ $GUESS -eq $NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
  elif [[ $GUESS -gt $NUMBER ]]
  then
    (( TRIES++ ))
    echo "It's lower than that, guess again:"
    read GUESS
  else
    (( TRIES++ ))
    echo "It's higher than that, guess again:"
    read GUESS
  fi
done

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (user_id, number_guesses) VALUES ($USER_ID, $TRIES)")

echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
