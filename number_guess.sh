#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#first prompt
echo Enter your username:
read USERNAME
#checking if USERNAME has been used before
EXISTING_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
# if user is new
if [[ -z $EXISTING_USER ]]
then
  #add new user to users table
  ADD_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  #greet new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  #check how many games user have played
  USER_GAMES=$($PSQL "SELECT COUNT(game_id) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME' ")
  #check best game
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME' ")
  # greet existing user
  echo Welcome back, $USERNAME! You have played $USER_GAMES games, and your best game took $BEST_GAME guesses.
fi

#generate a random number
SECRET_NUMBER=$((1 + $RANDOM % 1000 +1))

#print command take guess
echo "Guess the secret number between 1 and 1000:"
TRIES=1
while read GUESS
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      break;
    else
      if [[ $GUESS -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      elif [[ $GUESS -lt $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"  
      fi    
    fi
  fi
  TRIES=$(( $TRIES + 1 ))  
done

if [[ $TRIES == 1 ]]
  then
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
  else
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
  fi 

#get user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
#insert game results to game table
INSERT_GAME_RESULTS=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($TRIES, $USER_ID)")
