#!/bin/bash

# Exit when any command fails
set -e

# To use environment variables defined in .env:
export $(cat .env | sed 's/#.*//g' | xargs)

# Test database connection
dbt debug

# Load source data into data flow DB
# Download CSV files from Digital Ocean file storage
mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/pluto.csv pluto.csv
mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/attachments/zoning_districts.csv zoning_districts.csv
mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/attachments/source_data_versions.csv source_data_versions.csv

# Copy CSV files into source data tables
export BUILD_ENGINE_SERVER=postgresql://${BUILD_ENGINE_USER}:${BUILD_ENGINE_PASSWORD}@${BUILD_ENGINE_HOST}:${BUILD_ENGINE_PORT}
export BUILD_ENGINE_URI=${BUILD_ENGINE_SERVER}/${BUILD_ENGINE_DB}

psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/load_sources.sql

# Validate source data
dbt test --select "source:*"

# Create API tables in data flow DB
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file create_tables.sql

# Populate API tables in data flow DB
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file populate_tables.sql