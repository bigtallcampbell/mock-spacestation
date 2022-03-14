#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Provisions and starts the Mock-SpaceStation container
#
#

echo ""
echo "--------------------------------------------------"
echo "Mock-SpaceStation Deployment"
echo "Please wait wihle the Mock-SpaceStation is configured and deployed"

MOCK_SPACESTATION_NETWORK_NAME="mock-spacestation-vnet"
MOCK_SPACESTATION_CONTAINER_NAME="mock-spacestation"
MOCK_SPACESTATION_IMAGE_NAME="mock-spacestation-image"
MOCK_SPACESTATION_IMAGE_TAG="latest"
QUICK_START_IMAGE_NAME="mock-spacestation-quick-start-image"

#Passable Parameters:
quick_start=${quick_start:-quick_start}
quick_start = "False"

#Getting parameter values
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

if ! [ -f "/root/.ssh/id_rsa" ];then
    #SSH Keys don't exist.  Create them so we can use them in Mock-SpaceStation
    ssh-keygen -f /root/.ssh/id_rsa -N ''
fi

# GitHub Codespace workaround
if ! [ -d "/mock-groundstation" ]; then
    #mock-groundstation doesn't exist.  Create a symbolic link to point to it
    ln -s /workspaces/mock-spacestation /mock-groundstation
fi

if [ ! -d "/mock-groundstation/sync" ]; then
    #Sync directory doesn't exist.  Create it and add a placeholder file
    mkdir -p /mock-groundstation/sync
    echo "What is an astronaut's favorite dance?  The moonwalk!" > /mock-groundstation/sync/sample-file-from-ground.txt
fi

HAS_NETWORK=$(docker network ls | grep $MOCK_SPACESTATION_NETWORK_NAME)
if [ -z "${HAS_NETWORK}" ]; then
    docker network create --internal $MOCK_SPACESTATION_NETWORK_NAME
fi

CONTAINER_RUNNING=$(docker container ls | grep $MOCK_SPACESTATION_CONTAINER_NAME)
if [ -z "${CONTAINER_RUNNING}" ]; then #Grep results is null.  Container is not running

    #Check if our switchboard is provisioned but stopped.  If so, dump it
    CONTAINER_RUNNING=$(docker container ls -a | grep $MOCK_SPACESTATION_CONTAINER_NAME)
    if [ -n "${CONTAINER_RUNNING}" ]; then
        echo -n "removing stopped instance..."
        docker rm $MOCK_SPACESTATION_CONTAINER_NAME --force
    fi

    IMAGE_DEPLOYED=$(docker images | grep $MOCK_SPACESTATION_IMAGE_NAME)
    if [ -z "${IMAGE_DEPLOYED}" ]; then #Grep results is null.  Image is not deployed.  Deploy build it
        docker build -t "$MOCK_SPACESTATION_IMAGE_NAME:$MOCK_SPACESTATION_IMAGE_TAG" --no-cache -f /mock-groundstation/.devcontainer/Dockerfile.SpaceStation /mock-groundstation/.devcontainer
        if [ $quick_start = "True" ]; then 
            docker build -t "$QUICK_START_IMAGE_NAME:$MOCK_SPACESTATION_IMAGE_TAG" --no-cache -f /mock-groundstation/.devcontainer/Dockerfile.QuickStart /mock-groundstation/.devcontainer
        fi
    fi

    docker run -d -id --init --privileged --restart=always --mount "source=space-station-dind-var-lib-docker,target=/var/lib/docker,type=volume" --network $MOCK_SPACESTATION_NETWORK_NAME --name $MOCK_SPACESTATION_CONTAINER_NAME "$MOCK_SPACESTATION_IMAGE_NAME:$MOCK_SPACESTATION_IMAGE_TAG"
    if [ $quick_start = "True" ]; then 
        docker run -d -id --init --privileged --restart=always --mount "source=space-station-dind-var-lib-docker,target=/var/lib/docker,type=volume" --network $MOCK_SPACESTATION_NETWORK_NAME --name $MOCK_SPACESTATION_CONTAINER_NAME "$QUICK_START_IMAGE_NAME:$MOCK_SPACESTATION_IMAGE_TAG"
    fi

fi

HAS_NETWORK=$(docker network ls | grep $MOCK_SPACESTATION_NETWORK_NAME)
if [ -z "${HAS_NETWORK}" ]; then
    docker network create --internal $MOCK_SPACESTATION_NETWORK_NAME
fi

MOCK_SPACESTATION_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $MOCK_SPACESTATION_CONTAINER_NAME)

HAS_HOSTS_ENTRY=$(cat /etc/hosts | grep $MOCK_SPACESTATION_CONTAINER_NAME)
if [ -z "${HAS_HOSTS_ENTRY}" ]; then
    echo "$MOCK_SPACESTATION_IP $MOCK_SPACESTATION_CONTAINER_NAME" >> /etc/hosts
fi

HAS_KNOWN_HOSTS=$(cat /root/.ssh/known_hosts | grep $MOCK_SPACESTATION_CONTAINER_NAME)
if [ -z "${HAS_KNOWN_HOSTS}" ]; then
    ssh-keyscan mock-spacestation >> /root/.ssh/known_hosts
    ssh-keyscan $MOCK_SPACESTATION_IP >> /root/.ssh/known_hosts
    docker cp /root/.ssh/id_rsa mock-spacestation:/root/.ssh/id_rsa
    docker cp /root/.ssh/id_rsa.pub mock-spacestation:/root/.ssh/id_rsa.pub
    docker cp /root/.ssh/id_rsa.pub mock-spacestation:/root/.ssh/authorized_keys
fi



chmod +x /mock-groundstation/sync-with-spacestation.sh

echo ""
echo "--------------------------------------------------"
echo "Mock-SpaceStation Successfully deployed"
echo ""
echo ""
bash /mock-groundstation/.devcontainer/motd/groundstation.sh
echo ""
echo ""
echo "To get started, open a new terminal, run sync, or start developing"


