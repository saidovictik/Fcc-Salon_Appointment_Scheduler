#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"


echo -e "\n~~~~~~~~~~~~ MY SALON ~~~~~~~~~~~~~\n"


echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  
   if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
 if [[ -z $SERVICES ]]
  then
    echo "No services available at this time. Please check back later."
 else

 echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
   echo "$SERVICE_ID) $NAME"
  
  done
 read SERVICE_ID_SELECTED
 if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
 then
 MAIN_MENU "That is not a number "
 else
   
 AVIABLE_SERVICES=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
 NAME_SERV=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
 if [[ -z $AVIABLE_SERVICES ]] 
 then
  MAIN_MENU "I could not find that service. What would you like to do?"
 else
 echo  -e "\nWhat's your phone number?"

 read CUSTOMER_PHONE
 CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
 if [[ -z $CUSTOMER_NAME ]]
  then
 echo -e "\nWhat's your name?"
 read CUSTOMER_NAME
 INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
   fi
   echo -e "\nWhat time would you like your $NAME_SERV, $CUSTOMER_NAME?"
   read SERVICE_TIME
   CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
   if [[ $SERVICE_TIME ]]
   then
    INSERT_SERV_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
   if [[ $INSERT_SERV_RESULT ]]
   then
  echo -e "\nI have put you down for a $NAME_SERV at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."


    fi
   fi
  fi
 fi
fi
}
MAIN_MENU
