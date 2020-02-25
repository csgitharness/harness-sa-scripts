#!/bin/bash

CLOUD_PROVIDER_NAME=""
MASTER_URL=""
SERVICE_ACCOUNT="changeMe"
ENV_TYPE=""
APP_NAME=""



fn_cloud_provider_prod(){
cd Setup/Cloud\ Providers/

echo "INFO: serviceAccount input"
yq w $CLOUD_PROVIDER_NAME-prod.yaml 'serviceAccountToken' $SERVICE_ACCOUNT --inplace

echo "INFO: serviceAccount input"
yq w $CLOUD_PROVIDER_NAME-test.yaml 'serviceAccountToken' $SERVICE_ACCOUNT --inplace


# echo "INFO: masterUrl input"
# yq w $CLOUD_PROVIDER_NAME-prod.yaml 'masterUrl' $MASTER_PROD_URL --inplace

# echo "INFO: masterUrl input"
# yq w $CLOUD_PROVIDER_NAME-test.yaml 'masterUrl' $MASTER_URL --inplace


echo "INFO: Selecting the application to scope to the cloud provider"
yq d $CLOUD_PROVIDER_NAME-prod.yaml 'usageRestrictions.appEnvRestrictions.[0].appFilter.filterType' --inplace
yq w $CLOUD_PROVIDER_NAME-prod.yaml 'usageRestrictions.appEnvRestrictions.[0].appFilter.entityNames[+]' $APP_NAME  --inplace
yq w $CLOUD_PROVIDER_NAME-prod.yaml 'usageRestrictions.appEnvRestrictions.[0].appFilter.filterType' SELECTED  --inplace

echo "INFO: Selecting the application to scope to the cloud provider"
yq d $CLOUD_PROVIDER_NAME-test.yaml 'usageRestrictions.appEnvRestrictions.[0].appFilter.filterType' --inplace
yq w $CLOUD_PROVIDER_NAME-test.yaml 'usageRestrictions.appEnvRestrictions.[0].appFilter.entityNames[+]' $APP_NAME  --inplace
yq w $CLOUD_PROVIDER_NAME-test.yaml 'usageRestrictions.appEnvRestrictions.[0].appFilter.filterType' SELECTED  --inplace


yq w $CLOUD_PROVIDER_NAME-prod.yaml 'usageRestrictions.appEnvRestrictions.[0].envFilter.filterTypes[0]' "PROD" --inplace
yq w $CLOUD_PROVIDER_NAME-test.yaml 'usageRestrictions.appEnvRestrictions.[0].envFilter.filterTypes[0]' "NON_PROD" --inplace

 
}

fn_summary_creation() {
echo "INFO: Summary of Cloud Provider Creation\n"
cat $CLOUD_PROVIDER_NAME-prod.yaml
cat $CLOUD_PROVIDER_NAME-test.yaml


sleep 2

fn_commit

}

fn_commit(){
echo "INFO: Adding files to Github commit"
git add -A
echo "Generating the commit"
git commit -m "harness.io script commiting cloud provider changes"

echo "Pushing code to github"
git push
}

### MAIN ####
if [ $# -lt 2 ]; then
echo "ERROR: Not enough arguments"
echo "Usage: ./cloud_provider_generator.sh <CLOUD_PROVIDER_NAME> <APP_NAME> "
exit 0
fi

if [ -d "Setup" ]; then 
    CLOUD_PROVIDER_NAME=$1
    # MASTER_URL=$2
    APP_NAME=$2
    echo "INFO: Creating Cloud Provider"
    fn_cloud_provider_prod
else 
  echo "ERROR: No Setup Directory Found"
fi

fn_summary_creation
