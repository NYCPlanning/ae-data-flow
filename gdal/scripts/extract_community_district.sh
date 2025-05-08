#! /bin/sh

LABEL=data/convert/community-district-label.json
if test -f "$LABEL"; then
    rm $LABEL
fi

FILL=data/convert/community-district-fill.json
if test -f "$FILL"; then
    rm $FILL
fi

PG_CONNECTION="dbname=$POSTGRES_DB host=ae-data-flow-db-1 user=$POSTGRES_USER port=5432"
ogr2ogr \
    -f GeoJSON \
    $FILL \
    PG:"$PG_CONNECTION" \
    -sql @scripts/community_district_fill.sql

ogr2ogr \
    -f GeoJSON \
    $LABEL \
    PG:"$PG_CONNECTION" \
    -sql @scripts/community_district_label.sql
