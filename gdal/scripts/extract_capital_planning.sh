#! /bin/sh

LABEL=data/convert/capital-planning-label.json
if test -f "$LABEL"; then
    rm $LABEL
fi

FILL=data/convert/capital-planning-fill.json
if test -f "$FILL"; then
    rm $FILL
fi

PG_CONNECTION="dbname=$POSTGRES_DB host=ae-data-flow-db-1 user=$POSTGRES_USER port=5432"
ogr2ogr \
    -f GeoJSON \
    $FILL \
    PG:"$PG_CONNECTION" \
    -sql @scripts/capital_planning_fill.sql

ogr2ogr \
    -f GeoJSON \
    $LABEL \
    PG:"$PG_CONNECTION" \
    -sql @scripts/capital_planning_label.sql
