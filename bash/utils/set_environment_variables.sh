#!/bin/bash

# Exit when any command fails
set -e

UTILS_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
ROOT_DIR=$(dirname ${UTILS_DIR})/../

function set_envars {
    export PGPASSWORD=$BUILD_ENGINE_PASSWORD
    # To use environment variables defined in .env:
    echo "setting environment variables from .env file ..."
    export $(cat $ROOT_DIR/.env | sed 's/#.*//g' | xargs)

    echo "setting other environment variables ..."
    export BUILD_ENGINE_SERVER=postgresql://${BUILD_ENGINE_USER}:${BUILD_ENGINE_PASSWORD}@${BUILD_ENGINE_HOST}:${BUILD_ENGINE_PORT}
    export BUILD_ENGINE_URI=${BUILD_ENGINE_SERVER}/${BUILD_ENGINE_DB}

    export BUILD_ZONING_API_DB_SERVER=postgresql://${ZONING_API_USER}:${ZONING_API_PASSWORD}@${ZONING_API_HOST}:${ZONING_API_PORT}
    export BUILD_ZONING_API_ENGINE_URI=${BUILD_ZONING_API_DB_SERVER}/${ZONING_API_DB}
}
