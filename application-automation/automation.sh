#!/bin/bash

## Variables
REFERENCE_APPLICATION="referenceRegulated"
INPUT_APPLICATION=""
INPUT_SERVICE=""
SERVICE_TYPE=""
PROD_NAMESPACE=""
TEST_NAMESPACE=""


fn_create_application(){
echo "INFO: Navigating to the Applications Folder"
cd Setup/Applications/
echo "INFO: Creating the application directory"
mkdir $INPUT_APPLICATION
echo "INFO: Copying content of template application into new application"
cp -a $REFERENCE_APPLICATION/. $INPUT_APPLICATION
echo "INFO: Created the new application"
cd $INPUT_APPLICATION
yq w Index.yaml 'description' $INPUT_APPLICATION --inplace
}

fn_create_service(){
## cd into the service and rename the service folder
echo "INFO: Navigating to Service"
cd ..
echo "INFO: Creating the service within the Application"
cd $INPUT_APPLICATION/Services 


mkdir $INPUT_SERVICE 

if [[ ${SERVICE_TYPE} == "helm" ]]; then
  cp -a referenceHelmK8sSvc/. $INPUT_SERVICE
fi

if [[ ${SERVICE_TYPE} == "k8s" ]]; then
  cp -a referenceNativeK8sSvc/. $INPUT_SERVICE
fi



echo "INFO: Navigating to $INPUT_SERVICE"
cd $INPUT_SERVICE 

echo "INFO: Editting the default description to service name"
yq w Index.yaml 'description' $INPUT_SERVICE --inplace

}

fn_mainpulate_namespace(){
namesArr=$(yq r Index.yaml 'variableOverrides[*].name' | xargs)
names=($(echo ${namesArr//- /}))
for i in "${!names[@]}"; do 
    if [[ ${names[$i]} == "namespace" ]]; then
        yq w Index.yaml "variableOverrides[$i].value" $1 --inplace 
    fi
done 
}


## Don't need to create a new evnironment edit this
fn_create_environment(){

echo "INFO: Navigating to Environments"
cd ../..
cd Environments/prod


echo "INFO: Modifying namespace for prod environment"
fn_mainpulate_namespace $PROD_NAMESPACE


cd ../..



echo "INFO: Modifying namespace for test environment"
cd Environments/test


fn_mainpulate_namespace $TEST_NAMESPACE 


}



fn_edit_pipeline_service() {

echo "INFO: Navigating to Pipelines"
cd ../..
cd Pipelines

if [[ ${SERVICE_TYPE} == "helm" ]]; then
  touch "${INPUT_SERVICE} Test to Prod With Approval - Helm.yaml"

  cp -a Reference\ Test\ to\ Prod\ With\ Approval\ -\ Helm.yaml "${INPUT_SERVICE} Test to Prod With Approval - Helm.yaml"
  echo "INFO: Editting Test Environment Stage of Helm Pipeline"
  yq w "${INPUT_SERVICE} Test to Prod With Approval - Helm.yaml" 'pipelineStages.[0].workflowVariables[2].value' $INPUT_SERVICE --inplace
  echo "INFO: Editting Prod Environment Stage of Helm Pipeline"
  yq w "${INPUT_SERVICE} Test to Prod With Approval - Helm.yaml" 'pipelineStages.[2].workflowVariables[2].value' $INPUT_SERVICE --inplace
fi

if [[ ${SERVICE_TYPE} == "k8s" ]]; then 
  touch "${INPUT_SERVICE} Test to Prod With Approval - Vanilla Kubernetes Manifests.yaml"
  cp -a Reference\ Test\ to\ Prod\ With\ Approval\ -\ Vanilla\ Kubernetes\ Manifests.yaml "${INPUT_SERVICE} Test to Prod With Approval - Vanilla Kubernetes Manifests.yaml"
  echo "INFO: Editting Test Environment Stage of K8s Pipeline"
  yq w "${INPUT_SERVICE} Test to Prod With Approval - Vanilla Kubernetes Manifests.yaml" 'pipelineStages.[0].workflowVariables[2].value' $INPUT_SERVICE --inplace
  echo "INFO: Editting Prod Environment Stage of K8s Pipeline"
  yq w "${INPUT_SERVICE} Test to Prod With Approval - Vanilla Kubernetes Manifests.yaml" 'pipelineStages.[2].workflowVariables[2].value' $INPUT_SERVICE --inplace
fi


}



fn_print_summary() {

echo "INFO: Navigating to Setup\n"
cd ../../../..

echo "INFO: Generating Summary\n"
echo "***** SUMMARY OF APPLICATION *****\n"
cat "Setup/Applications/$INPUT_APPLICATION/Index.yaml"
echo "***** SUMMARY OF SERVICE ******\n"
cat Setup/Applications/$INPUT_APPLICATION/Services/$INPUT_SERVICE/Index.yaml
echo "***** SUMMARY OF SERVICE MANIFEST *****\n"
cat Setup/Applications/$INPUT_APPLICATION/Services/$INPUT_SERVICE/Manifests/Index.yaml
echo "***** SUMMARY OF Prod ENVIRONMENTS ******\n"
cat Setup/Applications/$INPUT_APPLICATION/Environments/prod/Index.yaml
echo "***** SUMMARY OF Test ENVIRONMENTS ******\n"
cat Setup/Applications/$INPUT_APPLICATION/Environments/test/Index.yaml

if [[ -d "Setup/Applications/$INPUT_APPLICATION" ]]; then

  fn_commit

fi
}

fn_commit(){
echo "INFO: Adding files to Github commit"
git add -A
echo "Generating the commit"
git commit -m "harness.io script commiting cloud provider changes"

echo "Pushing code to github"
git push
}

###### MAIN #####
echo "****** Generating a new Harness Application *******"

if [ $# -lt 5 ]; then
echo "ERROR: Not enough arguments"
echo "Usage: <Application_Name> <Service_Name> <Service_type> <PROD_Namespace> <TEST_Namespace>"
exit 0
fi


if [ -d "Setup" ]; then
  if [ -d "Setup/Applications/$REFERENCE_APPLICATION" ]; then
    INPUT_APPLICATION=$1
    INPUT_SERVICE=$2
    SERVICE_TYPE=$3
    PROD_NAMESPACE=$4
    TEST_NAMESPACE=$5

    echo "INFO: Creating application"
    fn_create_application

    echo "INFO: Creating Service"
    fn_create_service

    echo "INFO: Creating Environment"
    fn_create_environment

    echo "INFO: Creating Pipeline"
    fn_edit_pipeline_service
  else 
    echo "ERROR: Reference Application is needed to execute the script"
  fi
else 
  echo "ERROR: Script needs to be executed in the setup directory"
fi


fn_print_summary




