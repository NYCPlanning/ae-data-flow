#! /bin/sh

FILE=data/convert/dcp_community_districts.json
if test -f "$FILE"; then
    rm $FILE
fi

ogr2ogr \
    -f GeoJSON \
    -t_srs EPSG:4326 \
    -sql @scripts/community_districts.sql \
    data/convert/dcp_community_districts.json \
    data/download/dcp_community_districts.shp.zip
