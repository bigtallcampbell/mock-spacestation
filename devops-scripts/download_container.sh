#!/bin/bash

image_name=${image_name:-image_name}
account_name=${account_name:-account_name}
account_key=${account_key:-account_key}
download_path=${download_path:-download_path}

#Getting parameter values
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

echo "Downloading Code for ISS Execution"
echo ""
echo "Creating Test Results Directory"
mkdir $download_path/results

echo "Creating container image directory"
mkdir $download_path/container_image

echo "Download Container Image"
az storage blob download --account-name $account_name --account-key $account_key -c dockerimage -f ./container_image/container.tar -n container.tar

echo "Creating Config directory"
mkdir $download_path/config

echo "Download Configuration Files"
az storage blob download --account-name $account_name --account-key $account_key -c dockerconfig -f ./config/config.json -n config.json

echo "Creating Scripts Directory"
mkdir $download_path/scripts

echo "Download Script Files"
az storage blob download --account-name $account_name --account-key $account_key -c scripts -f ./scripts/docker_cleanup.sh -n docker_cleanup.sh
az storage blob download --account-name $account_name --account-key $account_key -c scripts -f ./scripts/download_container.sh -n download_container.sh
az storage blob download --account-name $account_name --account-key $account_key -c scripts -f ./scripts/run_experiment.sh -n run_experiment.sh

echo ""
echo "All Code Downloaded Successfully"