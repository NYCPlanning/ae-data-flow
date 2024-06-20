#!/bin/bash

# Exit when any command fails
set -e

# transfer shapefiles to data tables
echo "Importing shapefiles into DB ..."
### TODO: configure the filepath for pointing to folders
## project multipoints
ogr2ogr -nln capital_project_source_m_pnt \
  -nlt PROMOTE_TO_MULTI \
  PG:${BUILD_ENGINE_URI} \
  .data/cpdb_dcpattributes_pts \
  -lco precision=NO \
  -lco GEOMETRY_NAME=geom

## project multipolygons
ogr2ogr -nln capital_project_source_m_poly \
  -nlt PROMOTE_TO_MULTI \
  PG:${BUILD_ENGINE_URI} \
  .data/cpdb_dcpattributes_poly \
  -lco precision=NO \
  -lco GEOMETRY_NAME=geom


## city council districts
ogr2ogr -nln city_council_district_source \
  -nlt PROMOTE_TO_MULTI \
  PG:${BUILD_ENGINE_URI} \
  .data/dcp_city_council_districts \
  -lco precision=NO \
  -lco GEOMETRY_NAME=geom


## community districts
ogr2ogr -nln community_district_source \
  -nlt PROMOTE_TO_MULTI \
  PG:${BUILD_ENGINE_URI} \
  .data/dcp_community_districts \
  -lco precision=NO \
  -lco GEOMETRY_NAME=geom


# Copy CSV files into source data tables
echo "Importing csv files into DB ..."
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/load_sources.sql

# Test database connection
echo "Testing imported data ..."
dbt debug
# Validate source data
dbt test --select "source:*"
