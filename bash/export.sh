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
    pg_dump -Fc --no-owner \
      -t tax_lot \
      -t borough \
      -t land_use \
      -t zoning_district \
      -t zoning_district_class \
      -t zoning_district_zoning_district_class \
      -t agency \
      -t agency_budget \
      -t budget_line \
      -t capital_commitment_fund \
      -t capital_commitment_type \
      -t capital_project \
      -t capital_project_checkbook \
      -t capital_project_fund \
      -t captial_commitment \
      -t city_council_district \
      -t community_district \
      -t managing_code \
      ${BUILD_ENGINE_URI} > db.dump
)
