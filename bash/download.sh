#!/bin/bash

# Exit when any command fails
set -e

FILE_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$FILE_DIR/../

source $ROOT_DIR/bash/utils/set_environment_variables.sh

# Setting Environmental Variables
set_envars

# set alias
mc alias set spaces $DO_SPACES_ENDPOINT $DO_SPACES_ACCESS_KEY $DO_SPACES_SECRET_KEY

# Download CSV files from Digital Ocean file storage
DATA_DIRECTORY=.data/
mkdir -p ${DATA_DIRECTORY} && (
    cd ${DATA_DIRECTORY}
    # zoning and tax lots
    mc cp spaces/edm-distributions/dcp_pluto/23v3/pluto.csv pluto.csv
    mc cp spaces/edm-distributions/dcp_pluto/23v3/attachments/zoning_districts.csv zoning_districts.csv
    mc cp spaces/edm-distributions/dcp_pluto/23v3/attachments/source_data_versions.csv source_data_versions.csv

    # capital planning
    mc cp spaces/edm-publishing/db-cpdb/publish/latest/cpdb_planned_commitments.csv cpdb_planned_commitments.csv
    mc cp spaces/edm-publishing/db-cpdb/publish/latest/cpdb_projects.csv cpdb_projects.csv
    mc cp spaces/edm-publishing/db-cpdb/publish/latest/cpdb_dcpattributes_pts.shp.zip cpdb_dcpattributes_pts.shp.zip
    unzip -o cpdb_dcpattributes_pts.shp.zip -d cpdb_dcpattributes_pts.shp
    mc cp spaces/edm-publishing/db-cpdb/publish/latest/cpdb_dcpattributes_poly.shp.zip cpdb_dcpattributes_poly.shp.zip
    unzip -o cpdb_dcpattributes_poly.shp.zip -d cpdb_dcpattributes_poly.shp
 
)

