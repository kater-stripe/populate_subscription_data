#!/bin/bash

# ACCOUNT_ID=yourStripeAccountId for reference only
API_KEY=YOUR_SECRET_KEY

prices=(price_1N1aqAIy2mCtTxFu1iIFS5pH price_1N1aqAIy2mCtTxFu3Xh4LCHg price_1N1aqAIy2mCtTxFuEOMfkWcu) #update to add priceIDs
datetime=("Sun Jan 01 07:00:00 GMT 2023" "Wed Feb 01 07:00:00 GMT 2023" "Wed Mar 01 07:00:00 GMT 2023") #add datetimes  
count=1

echo "no.,cus_id,cus_name,price_id,sub_id,start_date,sub_item_id,test_clock_id" > log.csv


create_testclock () {
    
    date="$1 $2 $3 $4 $5 $6"
    UNIX_TIME=$(date -j -f "%a %b %d %T %Z %Y" "$date" "+%s")

    TEST_CLOCK_ID=$(curl -X POST "https://api.stripe.com/v1/test_helpers/test_clocks" \
    -u $API_KEY:  \
    -d "frozen_time"=$UNIX_TIME \
    -d "name"="Monthly Subscription" | jq '.id')
    
    # return $TEST_CLOCK_ID
    if [ -z "$TEST_CLOCK_ID" ]; then
        echo 'no test clock id found'
      return 1
    else
      return 0
    fi

}


create_customer () {

    TEST_CLOCK=$(echo "$1" | sed "s/\"//g; s/ //g") 

    cus_data=$(curl https://api.namefake.com/)
    
    CUS_NAME="$(echo $cus_data | jq '.name' | sed "s/\"//g")"

    email="$(echo $cus_data | jq '.email_u')"@"$(echo $cus_data | jq '.email_d')"
    CUS_EMAIL=$(echo "$email" | sed "s/\"//g; s/ //g")

    CUSTOMER=$(curl -X POST "https://api.stripe.com/v1/customers" \
    -u $API_KEY:  \
    -d "name"="$CUS_NAME" \
    -d "email"="$CUS_EMAIL" \
    -d "payment_method"="pm_card_us" \
    -d "invoice_settings[default_payment_method]"="pm_card_us" \
    -d "test_clock"=$TEST_CLOCK
    )

    # return $CUSTOMER
    if [ -z "$CUSTOMER" ]; then
        echo 'no customer created'
      return 1
    else 
      return 0
    fi

}


for price in ${prices[@]}; do

    for date in $(echo ${!datetime[@]}); do

      it_date=$(echo ${datetime[$date]})

        for i in {1..5} ; do     

            create_testclock $it_date
            create_customer $TEST_CLOCK_ID

            CUS_ID=$(echo $CUSTOMER | jq '.id'| sed "s/\"//g")
            CUS_FullName=$(echo $CUSTOMER | jq '.name'| sed "s/\"//g")

            SUBSCRIPTION=$(curl -X POST "https://api.stripe.com/v1/subscriptions" \
                -u $API_KEY:  \
                -d "customer"="$CUS_ID" \
                -d "items[0][price]"="$price")

            SUB_ID=$(echo $SUBSCRIPTION | jq '.id'| sed "s/\"//g")
            SUB_ITEM_ID=$(echo $SUBSCRIPTION | jq ".items | .data | .[0].id")

            echo "$count,$CUS_ID,$CUS_FullName,$price,$SUB_ID,$date,$SUB_ITEM_ID,$TEST_CLOCK_ID" >> log.csv

            ((count++))
  
        done ## {1..5}_LOOP

    done ##DATE_LOOP

done ##PRICE_LOOP


