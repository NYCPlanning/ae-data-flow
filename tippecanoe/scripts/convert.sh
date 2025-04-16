#! /bin/sh

tippecanoe \
    -z13 \
    --projection=EPSG:4326 \
    -o data/convert/community-district-fill.pmtiles \
    -l community-district-fill data/convert/dcp_community_districts.json
