#!/bin/bash

# Exit when any command fails
set -e

# To use environment variables defined in .env:
export $(cat .env | sed 's/#.*//g' | xargs)

export BUILD_ZONING_API_DB_SERVER=postgresql://${ZONING_API_USER}:${ZONING_API_PASSWORD}@${ZONING_API_HOST}:${ZONING_API_PORT}
export BUILD_ZONING_API_ENGINE_URI=${BUILD_ZONING_API_DB_SERVER}/${ZONING_API_DB}

# Dump Zoning API DB tables to db.dump
pg_dump -Fc -t tax_lot -t borough -t land_use -t zoning_district -t zoning_district_class -t zoning_district_zoning_district_class ${BUILD_ENGINE_URI} > db.dump

# Restore Zoning API DB with updated data from db.dump
pg_restore --clean --if-exists -d ${BUILD_ZONING_API_ENGINE_URI} db.dump
