#!/bin/bash

set -e # exit on error
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
echo "Removing Docker Images (using Force)"
docker image rm $image_name -f
echo "Removed Docker Images (using Force)"