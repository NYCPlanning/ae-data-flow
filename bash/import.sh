#!/bin/bash

# Exit when any command fails
set -e

FILE_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$FILE_DIR/../

source $ROOT_DIR/bash/utils/set_environment_variables.sh

# Setting Environmental Variables
set_envars

# Test database connection
dbt debug

# transfer shapefiles to data tables
### TODO: configure the filepath for pointing to folders
## project multipoints
ogr2ogr -nln capital_project_source_m_pnt \
  -nlt PROMOTE_TO_MULTI \
  Pg:"dbname=$BUILD_ENGINE_DB host=$BUILD_ENGINE_HOST user=$BUILD_ENGINE_USER port=$BUILD_ENGINE_PORT" \
  .data/cpdb_dcpattributes_pts \
  -lco precision=NO \
  -lco GEOMETRY_NAME=geom

## project multipolygons
ogr2ogr -nln capital_project_source_m_poly \
  -nlt PROMOTE_TO_MULTI \
  Pg:"dbname=$BUILD_ENGINE_DB host=$BUILD_ENGINE_HOST user=$BUILD_ENGINE_USER port=$BUILD_ENGINE_PORT" \
  .data/cpdb_dcpattributes_poly \
  -lco precision=NO \
  -lco GEOMETRY_NAME=geom


## city council districts
ogr2ogr -nln city_council_district_source \
  -nlt PROMOTE_TO_MULTI \
  Pg:"dbname=$BUILD_ENGINE_DB host=$BUILD_ENGINE_HOST user=$BUILD_ENGINE_USER port=$BUILD_ENGINE_PORT" \
  .data/dcp_city_council_districts \
  -lco precision=NO \
  -lco GEOMETRY_NAME=geom


## community districts
ogr2ogr -nln community_district_source \
  -nlt PROMOTE_TO_MULTI \
  Pg:"dbname=$BUILD_ENGINE_DB host=$BUILD_ENGINE_HOST user=$BUILD_ENGINE_USER port=$BUILD_ENGINE_PORT" \
  .data/dcp_community_districts \
  -lco precision=NO \
  -lco GEOMETRY_NAME=geom


# Copy CSV files into source data tables

psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/load_sources.sql

# Validate source data
dbt test --select "source:*"
