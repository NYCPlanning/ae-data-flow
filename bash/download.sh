#!/bin/bash

# Exit when any command fails
set -e

# set alias
mc alias set spaces $DO_SPACES_ENDPOINT $DO_SPACES_ACCESS_KEY $DO_SPACES_SECRET_KEY

# Download CSV files from Digital Ocean file storage
DATA_DIRECTORY=.data/
mkdir -p ${DATA_DIRECTORY} && (
    cd ${DATA_DIRECTORY}
    echo "Downloading files for Zoning API ..."
    # zoning and tax lots (pluto 23v3)
    mc cp spaces/ae-data-backups/zoning-api/pluto.csv pluto.csv
    mc cp spaces/ae-data-backups/zoning-api/zoning_districts.csv zoning_districts.csv
    mc cp spaces/ae-data-backups/zoning-api/source_data_versions.csv source_data_versions.csv

    # capital planning
    echo "Downloading files for Capital Projects API ..."
    mc cp spaces/edm-publishing/db-cpdb/publish/latest/cpdb_planned_commitments.csv cpdb_planned_commitments.csv
    mc cp spaces/edm-publishing/db-cpdb/publish/latest/cpdb_projects.csv cpdb_projects.csv
    mc cp spaces/edm-publishing/db-cpdb/publish/latest/cpdb_dcpattributes_pts.shp.zip cpdb_dcpattributes_pts.shp.zip
    unzip -o cpdb_dcpattributes_pts.shp.zip -d cpdb_dcpattributes_pts
    mc cp spaces/edm-publishing/db-cpdb/publish/latest/cpdb_dcpattributes_poly.shp.zip cpdb_dcpattributes_poly.shp.zip
    unzip -o cpdb_dcpattributes_poly.shp.zip -d cpdb_dcpattributes_poly
    mc cp spaces/edm-publishing/datasets/dcp_city_council_districts/24B/dcp_city_council_districts.zip dcp_city_council_districts.zip
    unzip -o dcp_city_council_districts.zip -d dcp_city_council_districts
    mc cp spaces/edm-publishing/datasets/dcp_community_districts/24B/dcp_community_districts.zip dcp_community_districts.zip
    unzip -o dcp_community_districts.zip -d dcp_community_districts
)

