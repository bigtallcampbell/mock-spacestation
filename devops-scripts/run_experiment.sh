#!/bin/bash

set -e # exit on error

tar_file=${tar_file:-tar_file}
image_name=${image_name:-image_name}

#Getting parameter values
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

this_script_path=$(realpath "${BASH_SOURCE%/*}")

echo "Running Experiment"
echo ""

results_dir=$(realpath "$this_script_path"/../results)
echo "Results Directory = $results_dir"

config_dir=$(realpath "$this_script_path"/../config)
echo "Config Directory = $config_dir"

container_dir=$(realpath "$this_script_path"/../container_image)
echo "Container Directory = $container_dir"

echo ""
echo "Loading Docker image"
docker load -i "$container_dir/$tar_file"

echo "Docker Image Loaded"
echo "Confirming docker image loaded"
docker images $image_name

echo -n "Is your image \"$image_name\" listed above? Y/n : "
read -r image_config

if [ "$image_config" = "Y" ];
then
    echo "Image Found - $image_name"
    echo ""

    echo "Removing Old Configuration File"
    rm "$config_dir/config.json"
    echo "Old Configuration File Deleted"

    echo "Running Docker Container"
    echo ""
    docker run -v "/$results_dir:/variantreads" -v "/$config_dir:/config" $image_name:latest
    echo ""
    echo "Docker Container Finished Executing"

    echo ""
    echo "Experiment Complete"
else
    echo "Image Not Found"
fi
