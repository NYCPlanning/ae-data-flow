#!/bin/bash

# Exit when any command fails
set -e

FILE_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$FILE_DIR/../

DATA_DIRECTORY=.data/

source $ROOT_DIR/bash/utils/set_environment_variables.sh

# Setting Environmental Variables
set_envars

mkdir -p ${DATA_DIRECTORY} && (
    cd ${DATA_DIRECTORY}
    # Replace tables in Zoning API DB with updated data from db.dump
    pg_restore --no-owner --clean -d ${BUILD_ZONING_API_ENGINE_URI} db.dump
)