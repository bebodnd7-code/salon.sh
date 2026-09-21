#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ Salon ~~~~\n"

AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done

read SERVICE_ID_SELECTED
SERVICE_FOUND_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

while [[ -z $SERVICE_FOUND_RESULT ]] 
do
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_FOUND_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
done

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

echo -e "\nWhat is your phone number?"
read CUSTOMER_PHONE

CUSTOMER_FOUND_RESULT=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_FOUND_RESULT ]]
then
  echo -e "\nWhat is your name?"
  read CUSTOMER_NAME

  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

echo -e "\nWhat time would you like your appointment?"
read SERVICE_TIME

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
