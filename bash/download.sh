#!/bin/bash

# Exit when any command fails
set -e

# To use environment variables defined in .env:
export $(cat .env | sed 's/#.*//g' | xargs)

# Download CSV files from Digital Ocean file storage
DATA_DIRECTORY=.data/
mkdir -p ${DATA_DIRECTORY} && (
    cd ${DATA_DIRECTORY}
    mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/pluto.csv pluto.csv
    mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/attachments/zoning_districts.csv zoning_districts.csv
    mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/attachments/source_data_versions.csv source_data_versions.csv
)
