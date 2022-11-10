#!/bin/bash

 PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

 LIST () {
         if [[ $1 ]]
         then
                 echo -e "\n$1"
         fi

         echo -e "\n~~ Here are our services ~~\n"
         SERVICES=$($PSQL "SELECT * FROM services")

         echo "$SERVICES" | while IFS="|" read NUMBER SERVICE
 do
         echo "$NUMBER) $SERVICE"
 done

         echo -e "\nWhich one would you like to take today?"
         read SERVICE_ID_SELECTED

         case $SERVICE_ID_SELECTED in
                 1) SERVICE_ID_SELECTED=1 ;;
                 2) SERVICE_ID_SELECTED=2 ;;
                 3) SERVICE_ID_SELECTED=3 ;;
                 *) LIST "### We don't have that service option for now, please enter a valid one ###" ;;
         esac	 

	 return $SERVICE_ID_SELECTED
 }

 MAIN_MENU () {

         echo -e "\nPlease, enter your phone number"
         read CUSTOMER_PHONE

         CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

         if [[ -z $CUSTOMER_ID ]]
         then
                 echo -e " \nWhat's your name?"
                 read CUSTOMER_NAME

                 INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
                 CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
         fi

         echo -e "\nAt what time do you want your appointment to be set?"
         read SERVICE_TIME

         INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

         if [[ $INSERT_APPOINTMENT =~ INSERT.* ]]
         then
                 APPOINTMENT_ID=$($PSQL "SELECT appointment_id FROM appointments WHERE customer_id = $CUSTOMER_ID AND service_id = $SERVICE_ID_SELECTED AND time = '$SERVICE_TIME'")

                 APPOINTMENT=$($PSQL "SELECT services.name, time, customers.name FROM services INNER JOIN appointments USING (service_id) INNER JOIN customers USING (customer_id) WHERE appointments.appointment_id = '$APPOINTMENT_ID'")

                 echo "$APPOINTMENT" | while IFS="|" read SERVICE TIME NAME
                 do
                 echo -e "\nI have put you down for a $SERVICE at $TIME, $NAME."
                 done
         fi



 }
 LIST
 MAIN_MENU
