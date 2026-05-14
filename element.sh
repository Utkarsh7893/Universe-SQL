#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

# If no argument given
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Determine if input is a number, symbol, or name
if [[ $1 =~ ^[0-9]+$ ]]; then
  # Input is atomic number
  ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
    FROM elements e
    JOIN properties p ON e.atomic_number = p.atomic_number
    JOIN types t ON p.type_id = t.type_id
    WHERE e.atomic_number = $1")
elif [[ ${#1} -le 2 && $1 =~ ^[A-Za-z]+$ ]]; then
  # Input is likely a symbol
  ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
    FROM elements e
    JOIN properties p ON e.atomic_number = p.atomic_number
    JOIN types t ON p.type_id = t.type_id
    WHERE e.symbol = '$1'")
  # If not found as symbol, try name
  if [[ -z $ELEMENT ]]; then
    ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
      FROM elements e
      JOIN properties p ON e.atomic_number = p.atomic_number
      JOIN types t ON p.type_id = t.type_id
      WHERE e.name = '$1'")
  fi
else
  # Input is a name
  ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
    FROM elements e
    JOIN properties p ON e.atomic_number = p.atomic_number
    JOIN types t ON p.type_id = t.type_id
    WHERE e.name = '$1'")
  # If not found as name, try symbol
  if [[ -z $ELEMENT ]]; then
    ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
      FROM elements e
      JOIN properties p ON e.atomic_number = p.atomic_number
      JOIN types t ON p.type_id = t.type_id
      WHERE e.symbol = '$1'")
  fi
fi

# If element not found
if [[ -z $ELEMENT ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Parse result
IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ELEMENT"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
#abc