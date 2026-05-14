#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Prompt for username
echo "Enter your username:"
read USERNAME

# Check if user exists
USER_INFO=$($PSQL "SELECT user_id, username FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]; then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  
  # Insert new user
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # Existing user
  IFS="|" read USER_ID USERNAME <<< "$USER_INFO"
  
  # Get games played and best game
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Start guessing game
echo "Guess the secret number between 1 and 1000:"
GUESSES=0

while true; do
  read GUESS
  GUESSES=$((GUESSES + 1))
  
  # Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
  
  # Check if guess is correct
  if [[ $GUESS -eq $SECRET_NUMBER ]]; then
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
done

# Insert game result
INSERT_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES)")
#abcd