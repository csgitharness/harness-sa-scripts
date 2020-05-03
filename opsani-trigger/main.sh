#!/bin/bash 


### VARIABLES
CPU=$1 
MEMORY=$2 
APP_NAME=$3

clone(){
	
}


fn_commit(){
echo "INFO: Adding files to Github commit"
git add -A
echo "Generating the commit"
git commit -m "harness.io script commiting cloud provider changes"

echo "Pushing code to github"
git push
}

fn_nav_trigger(){
	cd Setup/Applications/$APP_NAME/Triggers

}

#Edit the CPU Value
fn_mainpulate_cpu(){
namesArr=$(yq r trigger.yml 'workflowVariables[*].name' | xargs)
names=($(echo ${namesArr//- /}))
for i in "${!names[@]}"; do 
    if [[ ${names[$i]} == "cpu" ]]; then
        yq w trigger.yml "workflowVariables[$i].value" $1 --inplace 
    fi
done 
}


#Edit the Memory Value
fn_mainpulate_memory(){
namesArr=$(yq r trigger.yml 'workflowVariables[*].name' | xargs)
names=($(echo ${namesArr//- /}))
for i in "${!names[@]}"; do 
    if [[ ${names[$i]} == "mem" ]]; then
        yq w trigger.yml "workflowVariables[$i].value" $2 --inplace 
    fi
done 
}


### MAIN

if [ $# -lt 3 ]; then
echo "ERROR: Not enough arguments"
echo "Usage: ./main.sh <cpuVal> <memVal> <APP_NAME>"
exit 0
fi

if [ -d "Setup" ]; then 
    CPU=$1
    MEM=$2
    APP_NAME=$3
	
	
	echo "INFO: Navigating to Trigger YML"
    fn_nav_trigger
	
	echo "Manipulating the cpu"
	fn_mainpulate_cpu
	
	echo "Manipulating Memory"
	fn_mainpulate_memory
	
	echo "Commiting to GitHub"
	commit
	
else 
  echo "ERROR: No Setup Directory Found"
fi
