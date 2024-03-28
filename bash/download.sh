#!/bin/bash

# Exit when any command fails
set -e

FILE_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$FILE_DIR/../

source $ROOT_DIR/bash/utils/set_environment_variables.sh

# Setting Environmental Variables
set_envars

# Download CSV files from Digital Ocean file storage
DATA_DIRECTORY=.data/
mkdir -p ${DATA_DIRECTORY} && (
    cd ${DATA_DIRECTORY}
    mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/pluto.csv pluto.csv
    mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/attachments/zoning_districts.csv zoning_districts.csv
    mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/attachments/source_data_versions.csv source_data_versions.csv
)
