#!/bin/bash
# Salon Appointment Scheduler - freeCodeCamp

# Para evitar que pida la pass todo el tiempo
export PGPASSWORD="freecodecamp"

PSQL="psql -X --username=freecodecamp --host=127.0.0.1 --dbname=salon --no-align --tuples-only -c"

# Función para eliminar espacios extra
trim() {
  echo "$1" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g'
}

# Mostrar lista de servicios
print_services() {
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICE_LIST" | while IFS="|" read SID SNAME
  do
    echo "$SID) $SNAME"
  done
}

main_menu() {
  if [[ -n $1 ]]; then
    echo -e "\n$1"
  fi
  echo -e "\nWelcome to My Salon, how can I help you?"
  print_services
  echo
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  SERVICE_NAME=$(trim "$SERVICE_NAME")

  if [[ -z $SERVICE_NAME ]]; then
    main_menu "I could not find that service. What would you like today?"
    return
  fi

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  CUSTOMER_ID=$(trim "$CUSTOMER_ID")

  if [[ -z $CUSTOMER_ID ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    CUSTOMER_NAME=$(trim "$CUSTOMER_NAME")
    $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    CUSTOMER_ID=$(trim "$CUSTOMER_ID")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
    CUSTOMER_NAME=$(trim "$CUSTOMER_NAME")
  fi

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

main_menu
