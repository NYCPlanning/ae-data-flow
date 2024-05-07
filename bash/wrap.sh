#!/bin/bash

set -e

FILE_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$FILE_DIR/../

source $ROOT_DIR/bash/utils/set_environment_variables.sh

# Setting Environmental Variables
set_envars

psql ${BUILD_ENGINE_URI} \
  -v ZONING_API_DB=$ZONING_API_DB ZONING_API_HOST=$ZONING_API_HOST \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/wrap-api-db.sql

