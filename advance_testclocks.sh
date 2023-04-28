#!/bin/bash

API_KEY=sk_test_51J5TgEIy2mCtTxFuop6FwXSO8Et7l7BWg6uCG0NVxvVtaylhlNsrGbDDiDeuMNt7eElRUbwuev37KVXEFlTQ8I8W00ytbBzRid
prices=(price_1N1aqAIy2mCtTxFu1iIFS5pH price_1N1aqAIy2mCtTxFu3Xh4LCHg price_1N1aqAIy2mCtTxFuEOMfkWcu) 
startdate=("Sun Jan 01 07:00:00 GMT 2023" "Wed Feb 01 07:00:00 GMT 2023" "Wed Mar 01 07:00:00 GMT 2023")
newdate=("Wed Mar 01 07:00:00 GMT 2023" "Sat Apr 01 07:00:00 GMT 2023" "Mon May 01 07:00:00 GMT 2023")
LOG_FILE=log.csv

echo "no.,cus_id,cus_name,price_id,sub_id,start_date,sub_item_id,test_clock_id,status" > test_clocks_log.csv

advance_testclock () {
    date="$2 $3 $4 $5 $6 $7"
    UNIX_TIME=$(date -j -f "%a %b %d %T %Z %Y" "$date" "+%s")
    echo $UNIX_TIME

    advance_testclock=$(curl -X POST "https://api.stripe.com/v1/test_helpers/test_clocks/$1/advance" \
    -u $API_KEY:  \
    -d "frozen_time"=$UNIX_TIME)

    status=$(echo $advance_testclock | jq ".status" | sed "s/\"//g")
    if [ -z "$status" ]; then
        echo 'no new frozen time found'
        return 1
    else
        return 0
    fi
}


while IFS="," read -r no cus_id cus_name price_id sub_id start_date sub_item_id test_clock_id; do

    # echo $no $cus_id $cus_name $price_id $sub_id $start_date $sub_item_id
   
   #remove quotations from test clock ID 
    testClockID=$(echo $test_clock_id | sed "s/\"//g")

    case $start_date in

        ${startdate[0]}) #Sun Jan 01 07:00:00 GMT 2023
            advance_testclock $testClockID ${newdate[0]}
            echo "$no,$cus_id,$cus_name,$price_id,$sub_id,$start_date,$sub_item_id,$test_clock_id,$status" >> test_clocks_log.csv
        ;;

         ${startdate[1]}) #Wed Feb 01 07:00:00 GMT 2023
           advance_testclock $testClockID ${newdate[1]}
            echo "$no,$cus_id,$cus_name,$price_id,$sub_id,$start_date,$sub_item_id,$test_clock_id,$status" >> test_clocks_log.csv
        ;;

        ${startdate[2]}) #Wed Mar 01 07:00:00 GMT 2023
            advance_testclock $testClockID ${newdate[2]}
            echo "$no,$cus_id,$cus_name,$price_id,$sub_id,$start_date,$sub_item_id,$test_clock_id,$status" >> test_clocks_log.csv
        ;;

    esac    

done < $LOG_FILE



