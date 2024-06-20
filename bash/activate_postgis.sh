#!/bin/bash

# Exit when any command fails
set -e

FILE_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$FILE_DIR/../

source $ROOT_DIR/bash/utils/set_environment_variables.sh

# Setting Environmental Variables
set_envars

# activate postgis extension
echo "Adding postgis extension to DB ..."
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/activate_postgis.sql

