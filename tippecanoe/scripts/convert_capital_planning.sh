#! /bin/sh

tippecanoe \
    -z14 \
    --projection=EPSG:4326 \
    -o data/convert/capital-planning-fill.pmtiles \
    -l capital-planning-fill data/convert/capital-planning-fill.json \
    --force

tippecanoe \
    -B4 \
    -z14 \
    --projection=EPSG:4326 \
    -o data/convert/capital-planning-label.pmtiles \
    -l capital-planning-label data/convert/capital-planning-label.json \
    --force


tile-join \
    -o data/convert/capital-planning \
    data/convert/capital-planning-fill.pmtiles \
    data/convert/capital-planning-label.pmtiles \
    --force
