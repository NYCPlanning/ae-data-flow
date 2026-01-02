#! /bin/sh

tippecanoe \
    -z13 \
    --projection=EPSG:4326 \
    -o tile-finish/interim/community-districts-fill.pmtiles \
    -l community-districts-fill data/tiles/extracted/community-districts-fill.json \
    --force

tippecanoe \
    -B4 \
    -z13 \
    --projection=EPSG:4326 \
    -o tile-finish/interim/community-districts-label.pmtiles \
    -l community-districts-label data/tiles/extracted/community-districts-label.json \
    --force

tile-join \
    -o data/tiles/finished/community-districts.pmtiles \
    tile-finish/interim/community-districts-fill.pmtiles \
    tile-finish/interim/community-districts-label.pmtiles \
    --force
