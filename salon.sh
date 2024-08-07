#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
   echo $1
  fi
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo -e "Welcome to My Salon, how can I help you?\n"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE BAR
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED
  #get service by id
  SERVICE_ID_RESULT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  #if service does not exist
  if [[ -z $SERVICE_ID_RESULT ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  #if service exists
  else
    #ask for number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      #ask for name
      echo -e "\nI don't have a record with that phone number, what's your name?"
      read CUSTOMER_NAME
      #add user with this number
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    echo -e "\nWhat time would you like your$SERVICE_ID_RESULT, $CUSTOMER_NAME?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a$SERVICE_ID_RESULT at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
