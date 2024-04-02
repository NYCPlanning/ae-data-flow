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
    # Dump Zoning API DB tables to db.dump
    pg_dump -Fc --no-owner -t tax_lot -t borough -t land_use -t zoning_district -t zoning_district_class -t zoning_district_zoning_district_class ${BUILD_ENGINE_URI} > db.dump

    # Restore Zoning API DB with updated data from db.dump
    pg_restore --no-owner --clean --if-exists -d ${BUILD_ZONING_API_ENGINE_URI} db.dump
)
