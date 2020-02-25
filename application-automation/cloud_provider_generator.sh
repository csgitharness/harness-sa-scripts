#!/bin/bash

CLOUD_PROVIDER_NAME=""
MASTER_URL=""
SERVICE_ACCOUNT="changeMe"




fn_cloud_provider(){
cd Setup/Cloud\ Providers/

touch $CLOUD_PROVIDER_NAME-prod.yaml 
touch $CLOUD_PROVIDER_NAME-test.yaml 

cp  Namespace\ dpt\ -\ Prod\ Cluster\ --\ referenceCloudProvider.yaml $CLOUD_PROVIDER_NAME-prod.yaml 
cp  Namespace\ dpt\ -\ Test\ Cluster\ --\ referenceCloudProvider.yaml $CLOUD_PROVIDER_NAME-test.yaml

echo "INFO: serviceAccount input"
yq w $CLOUD_PROVIDER_NAME-prod.yaml 'serviceAccountToken' $SERVICE_ACCOUNT --inplace

echo "INFO: serviceAccount input"
yq w $CLOUD_PROVIDER_NAME-test.yaml 'serviceAccountToken' $SERVICE_ACCOUNT --inplace

echo "INFO: masterUrl input"
yq w $CLOUD_PROVIDER_NAME-prod.yaml 'masterUrl' $MASTER_PROD_URL --inplace

echo "INFO: masterUrl input"
yq w $CLOUD_PROVIDER_NAME-test.yaml 'masterUrl' $MASTER_TEST_URL --inplace

echo "INFO: Cloud Provider Environment Scoping Restrictions for the application"
yq w $CLOUD_PROVIDER_NAME-prod.yaml 'usageRestrictions.appEnvRestrictions.[0].envFilter.filterTypes[0]' "PROD" --inplace
yq w $CLOUD_PROVIDER_NAME-test.yaml 'usageRestrictions.appEnvRestrictions.[0].envFilter.filterTypes[0]' "NON_PROD" --inplace



echo "INFO: Editting the Skip Validation field in the YAML" 
yq w $CLOUD_PROVIDER_NAME-prod.yaml 'skipValidation' "true" --inplace 

echo "INFO: Editting the Skip Validation field in the YAML" 
yq w $CLOUD_PROVIDER_NAME-test.yaml 'skipValidation' "true" --inplace 

echo "INFO: Use Kubernetes Delegate to False"
yq w $CLOUD_PROVIDER_NAME-prod.yaml 'useKubernetesDelegate' "false" --inplace 

echo "INFO: Use Kubernetes Delegate to False"
yq w $CLOUD_PROVIDER_NAME-test.yaml 'useKubernetesDelegate' "false" --inplace 
}

fn_summary_creation() {
echo "INFO: Summary of Cloud Provider Creation\n"
cat $CLOUD_PROVIDER_NAME-prod.yaml
cat $CLOUD_PROVIDER_NAME-test.yaml

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
if [ $# -lt 3 ]; then
echo "ERROR: Not enough arguments"
echo "Usage: ./cloud_provider_generator.sh <CLOUD_PROVIDER_NAME> <MASTER_PROD_URL> <MASTER_TEST_URL> "
exit 0
fi

if [ -d "Setup" ]; then 
    CLOUD_PROVIDER_NAME=$1
    MASTER_PROD_URL=$2
    MASTER_TEST_URL=$3
    echo "INFO: Creating Cloud Provider"
    fn_cloud_provider
else 
  echo "ERROR: No Setup Directory Found"
fi

sleep 2 

fn_commit

fn_summary_creation



