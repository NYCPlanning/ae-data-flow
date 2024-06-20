#!/bin/bash

# Exit when any command fails
set -e

# activate postgis extension
echo "Adding postgis extension to DB ..."
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/activate_postgis.sql
