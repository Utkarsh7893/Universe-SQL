#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  # Display services
  echo -e "\nHere is a list of our services:"
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS="|" read ID NAME; do
    echo "$ID) $NAME"
  done)"

  # Prompt for service
  echo -e "\nWhat service would you like? Enter a service_id:"
  read SERVICE_ID_SELECTED

  # Validate service
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE ]]; then
    MAIN_MENU "That service does not exist."
  else
    # Prompt for phone
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]; then
      # New customer - get name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # Insert new customer
      $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" > /dev/null
    fi

    # Get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Prompt for time
    echo -e "\nWhat time would you like your $(echo $SERVICE | xargs) appointment?"
    read SERVICE_TIME

    # Insert appointment
    $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" > /dev/null

    # Confirmation message
    echo -e "\nI have put you down for a $(echo $SERVICE | xargs) at $SERVICE_TIME, $(echo $CUSTOMER_NAME | xargs)."
  fi
}

MAIN_MENU