#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?\n"
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED
  
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
  # send to main menu
    INVALID_SERVICE
  else
    SERVICE_CHOSEN_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_CHOSEN_ID ]]
    then
      # send to main menu
      INVALID_SERVICE
    else
      VALID_SERVICE
    fi
    
  fi
}

INVALID_SERVICE() {
  MAIN_MENU "We are sorry! This option is not available."
}

VALID_SERVICE() {

  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # get appointment time
  echo -e "\nWhat time would you like to be attended to?"
  read SERVICE_TIME

  # insert appointment time
  INSERT_TIME_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_CHOSEN_ID, '$SERVICE_TIME')")

  # appointmente registered
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_CHOSEN_ID'")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."

}

MAIN_MENU
