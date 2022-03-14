#!/bin/bash

set -e # exit on error
#Named 
image_name=${image_name:-image_name}
account_name=${account_name:-account_name}
account_key=${account_key:-account_key}
config_file_path=${config_file_path:-config_file_path}

#Getting parameter values
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

echo "Step 1 - Build Docker Image"
docker build -t="$image_name:latest" -f="./DockerFile" .

echo "Step 2 - Save Docker Image"
docker save "$image_name:latest" > container.tar

echo "Step 3 - Build Storage containers"
az storage container create --account-name $account_name --account-key $account_key -n dockerimage
az storage container create --account-name $account_name --account-key $account_key -n dockerconfig
az storage container create --account-name $account_name --account-key $account_key -n scripts

echo "Step 4 - Upload docker tar file"
az storage blob upload --account-name $account_name --account-key $account_key -c dockerimage -f container.tar -n container.tar

echo "Step 5 - Upload Config Files"
az storage blob upload --account-name $account_name --account-key $account_key -c dockerconfig -f config_file_path/config.json -n config.json

echo "Step 6 - Upload Execution Scripts"
az storage blob upload --account-name $account_name --account-key $account_key -c scripts -f ./docker_cleanup.sh -n docker_cleanup.sh
az storage blob upload --account-name $account_name --account-key $account_key -c scripts -f ./download_container.sh -n download_container.sh
az storage blob upload --account-name $account_name --account-key $account_key -c scripts -f ./run_experiment.sh -n run_experiment.sh

echo "Prepartion Process Complete"