#!/bin/bash

# Exit when any command fails
set -e

# To use environment variables defined in .env:
export $(cat .env | sed 's/#.*//g' | xargs)
export BUILD_ENGINE_SERVER=postgresql://${BUILD_ENGINE_USER}:${BUILD_ENGINE_PASSWORD}@${BUILD_ENGINE_HOST}:${BUILD_ENGINE_PORT}
export BUILD_ENGINE_URI=${BUILD_ENGINE_SERVER}/${BUILD_ENGINE_DB}

# Test database connection
dbt debug

# Create API tables in data flow DB
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/create_tables.sql

# Populate API tables in data flow DB
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/populate_tables.sql
