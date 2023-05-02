#!/bin/bash

API_KEY=ADDSECRETKEY
prices=(price_1N1aqAIy2mCtTxFu1iIFS5pH price_1N1aqAIy2mCtTxFu3Xh4LCHg price_1N1aqAIy2mCtTxFuEOMfkWcu) #add prices for subscriptions from Dashboard 
LOG_FILE=log.csv

echo "no.,cus_id,cus_name,price_id,sub_id,start_date,sub_item_id,test_clock_id,sub_status" > cancel_log.csv

cancel_subscription () {

    cancel_subscription=$(curl -X DELETE https://api.stripe.com/v1/subscriptions/$1 \
    -u $API_KEY: )
           
    sub_status=$(echo $cancel_subscription | jq '.status'| sed "s/\"//g")

    if [ -z "$sub_status" ]; then
        echo 'no new status found'
        return 1
    else
        return 0
    fi
}


while IFS="," read -r no cus_id cus_name price_id sub_id start_date sub_item_id test_clock_id; do

    # echo $no $cus_id $cus_name $price_id $sub_id $start_date $sub_item_id,$sub_status

    case $price_id in

        ${prices[1]}) #200 
            cancel_subscription $sub_id 
            echo "$no,$cus_id,$cus_name,$price_id,$sub_id,$start_date,$sub_item_id,$test_clock_id,$sub_status" >> cancel_log.csv
        ;;    

    esac    

done < $LOG_FILE
