#!/bin/bash

# Exit when any command fails
set -e

UTILS_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
ROOT_DIR=$(dirname ${UTILS_DIR})/..

source ${ROOT_DIR}/bash/utils/set_environment_variables.sh

# Setting Environmental Variables
set_envars

# Delete any artifacts of a local Data Flow database
running_container_id=$(docker ps --all --quiet --filter name=${BUILD_ENGINE_CONTAINER_NAME})
if [ -n "$running_container_id" ]
then 
    echo "Stoping and deleting docker container ID ${running_container_id} ..."
    docker stop $running_container_id
    docker rm --force $running_container_id
else
    echo "Container ${BUILD_ENGINE_CONTAINER_NAME} not running"
fi

echo "Deleting database volume directory /db-volume ..."
rm -rf ${ROOT_DIR}/db-volume

# Create local Data Flow database
echo "Creating docker container ${BUILD_ENGINE_CONTAINER_NAME} ..."
docker compose up --detach
