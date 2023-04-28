#!/bin/bash

API_KEY=ADDSECRETKEY
prices=(price_1N1aqAIy2mCtTxFu1iIFS5pH price_1N1aqAIy2mCtTxFu3Xh4LCHg price_1N1aqAIy2mCtTxFuEOMfkWcu) #update prices for subscriptions
LOG_FILE=log.csv

echo "no.,cus_id,cus_name,price_id,sub_id,start_date,sub_item_id,new_price_id" > change_log.csv

change_subscription () {

    change_subscription=$(curl -X POST "https://api.stripe.com/v1/subscription_items/$1" \
    -u $API_KEY:  \
    -d "price"="$2")

    new_price_id=$(echo $change_subscription | jq ".price" | jq ".id" | sed "s/\"//g")

    if [ -z "$new_price_id" ]; then
        echo 'no new price id found'
        return 1
    else
        return 0
    fi
}


while IFS="," read -r no cus_id cus_name price_id sub_id start_date sub_item_id; do

    # echo $no $cus_id $cus_name $price_id $sub_id $start_date $sub_item_id

    case $price_id in

        ${prices[0]}) #100 
            change_subscription $sub_item_id ${prices[1]} 
            echo "$no,$cus_id,$cus_name,$price_id,$sub_id,$start_date,$sub_item_id,$new_price_id" >> change_log.csv
        ;;

         ${prices[1]}) #200
            change_subscription $sub_item_id ${prices[2]}
            echo "$no,$cus_id,$cus_name,$price_id,$sub_id,$start_date,$sub_item_id,$new_price_id" >> change_log.csv
        ;;

        ${prices[2]}) #300
            change_subscription $sub_item_id ${prices[0]}
            echo "$no,$cus_id,$cus_name,$price_id,$sub_id,$start_date,$sub_item_id,$new_price_id" >> change_log.csv
        ;;

    esac    

done < $LOG_FILE
