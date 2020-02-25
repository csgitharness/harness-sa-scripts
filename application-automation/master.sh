#!/bin/bash

### Variables ###
APP_NAME=$1
MASTER_PROD_URL=$2
MASTER_TEST_URL=$3
INPUT_SERVICE=$4
SERVICE_TYPE=$5
PROD_NAMESPACE=$6
TEST_NAMESPACE=$7

### MAIN ###


echo "USAGE: <APP_NAME> <MASTER_PROD_URL> <MASTER_TEST_URL> <APP_NAME> <SERVICE> <SERVICE_TYPE> <PROD_NAMESPACE> <TEST_NAMESPACE>"

if [ $# -lt 7 ]; then
echo "ERROR: Not enough arguments"
echo "USAGE: <APP_NAME> <MASTER_PROD_URL> <MASTER_TEST_URL> <APP_NAME> <SERVICE> <SERVICE_TYPE> <PROD_NAMESPACE> <TEST_NAMESPACE>"
exit 0
fi

echo "INFO: Creating Cloud Provider"
echo "INFO: Running Cloud Provider Script"
./cloud_provider_generator.sh $1 $2 $3 

sleep 5 


echo "INFO: Creating the Application"
echo "INFO: Running Application automation script"
./automation.sh $1 $4 $5 $6 $7

sleep 5

./edit_cloud_provider.sh $1 $1

echo "INFO: DONE"

