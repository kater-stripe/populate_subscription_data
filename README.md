# populate_subscription_data
bash scripts to populate subscription on a Stripe account


 
 Order to run scripts: 
 1. create_customer_subscription.sh
 2. change_subscription.sh
 3. advance_testclocks.sh
 4. cancel_subscription.sh
 
 Can alternate between Steps 2-4 depending on the desired scenario. 
 
Scripts 2-4 read the log.csv file created in Script 1 


#Manual tasks before running the scripts
1. create product in the dashboard
2. create price(s) associated to the product in the dashboard
3. replace price IDs in the create_customer_subscription on line 6. Each price ID is separated by a space. 
