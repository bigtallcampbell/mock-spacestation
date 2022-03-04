#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Provisions and starts the Mock-SpaceStation container
#
#

MOCK_SPACESTATION_NETWORK_NAME="ISS-vNet"
MOCK_SPACESTATION_CONTAINER_NAME="mock-spacestation"
MOCK_SPACESTATION_IMAGE_NAME="mock-spacestation-image"
MOCK_SPACESTATION_IMAGE_TAG="latest"

if ! [ -f "/root/.ssh/id_rsa" ];then
    #SSH Keys don't exist.  Create them so we can use them in Mock-SpaceStation
    ssh-keygen -f /root/.ssh/id_rsa -N ''
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
        docker build -t "$MOCK_SPACESTATION_IMAGE_NAME:$MOCK_SPACESTATION_IMAGE_TAG" --no-cache -f /workspaces/mock-spacestation/.devcontainer/Dockerfile.SpaceStation /
    fi

    docker run -d -id --init --privileged --restart=always --mount "source=space-station-dind-var-lib-docker,target=/var/lib/docker,type=volume" --name $MOCK_SPACESTATION_CONTAINER_NAME "$MOCK_SPACESTATION_IMAGE_NAME:$MOCK_SPACESTATION_IMAGE_TAG"

fi

MOCK_SPACESTATION_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $MOCK_SPACESTATION_CONTAINER_NAME)
ssh-keyscan $MOCK_SPACESTATION_IP >> /root/.ssh/known_hosts
echo "$MOCK_SPACESTATION_IP mock-spacestation" >> /etc/hosts

ssh-keyscan mock-spacestation >> /root/.ssh/known_hosts
docker cp /root/.ssh/id_rsa mock-spacestation:/root/.ssh/id_rsa
docker cp /root/.ssh/id_rsa.pub mock-spacestation:/root/.ssh/id_rsa.pub
docker cp /root/.ssh/id_rsa.pub mock-spacestation:/root/.ssh/authorized_keys
