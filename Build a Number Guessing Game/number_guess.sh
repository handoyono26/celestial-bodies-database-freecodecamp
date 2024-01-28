#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(($RANDOM % 1000 + 1))

echo Enter your username:
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo Guess the secret number between 1 and 1000:
read GUESS
NUMBER_OF_GUESSES=1

while [[ ! $GUESS -eq $RANDOM_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read GUESS
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
  fi
done

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
