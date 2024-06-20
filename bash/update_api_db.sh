#!/bin/bash

# Exit when any command fails
set -e

mkdir -p ${DATA_DIRECTORY} && (
    cd ${DATA_DIRECTORY}
    # Replace tables in Zoning API DB with updated data from db.dump
    echo "Replacing tables in API DB with tables in db.dump file ..."
    pg_restore --no-owner --clean --if-exists -d ${BUILD_ZONING_API_ENGINE_URI} db.dump
)