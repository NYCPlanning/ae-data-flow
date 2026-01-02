#! /bin/sh

DEST_FILE=data/tiles/extracted/$BUILD-fill.json

if test -f "$DEST_FILE"; then
    rm $DEST_FILE
fi

# # TODO: replace host and port with env variables
PG_CONNECTION="dbname=$POSTGRES_DB host=ae-data-flow-db-1 user=$POSTGRES_USER port=5432"
ogr2ogr \
    -f GeoJSON \
    $DEST_FILE \
    PG:"$PG_CONNECTION" \
    -sql @tile-extract/$BUILD-fill.sql
