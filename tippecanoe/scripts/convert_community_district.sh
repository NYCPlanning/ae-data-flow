#! /bin/sh

tippecanoe \
    -z20 \
    --projection=EPSG:4326 \
    -o data/convert/community-district-fill.pmtiles \
    -l community-district-fill data/convert/community-district-fill.json \
    --force

tippecanoe \
    -B4 \
    -z20 \
    --projection=EPSG:4326 \
    -o data/convert/community-district-label.pmtiles \
    -l community-district-label data/convert/community-district-label.json \
    --force


tile-join \
    -o data/convert/community-districts-20-boro-district.pmtiles \
    data/convert/community-district-fill.pmtiles \
    data/convert/community-district-label.pmtiles \
    --force
