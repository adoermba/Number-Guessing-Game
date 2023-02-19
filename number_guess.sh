#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read NAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_NEWUSER_RESULT=$($PSQL "INSERT INTO users(name) VALUES ('$NAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME'")
  PLAYED_GAMES=0
  BEST_GAME=99999
else
  PLAYED_GAMES=$($PSQL "SELECT played_games FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
  echo -e "Welcome back, $NAME! You have played $PLAYED_GAMES games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESSED_NUMBER
NUMBER_OF_GUESSES=1

while [[ $GUESSED_NUMBER != $SECRET_NUMBER ]]
do

  if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if (( $GUESSED_NUMBER < $SECRET_NUMBER ))
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi    
    (( NUMBER_OF_GUESSES++ ))
  fi

  read GUESSED_NUMBER
done

(( PLAYED_GAMES++ ))
if (( $NUMBER_OF_GUESSES < $BEST_GAME ))
then
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE user_id=$USER_ID")
fi
UPDATE_PLAYED_GAMES_RESULT=$($PSQL "UPDATE users SET played_games=$PLAYED_GAMES WHERE user_id=$USER_ID")

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
