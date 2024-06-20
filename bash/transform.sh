#!/bin/bash

# Exit when any command fails
set -e

# Create API tables in data flow DB
echo "Creating API tables in DB ..."
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/create_tables.sql

# Populate API tables in data flow DB
echo "Populating API tables in DB ..."
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/populate_tables.sql
