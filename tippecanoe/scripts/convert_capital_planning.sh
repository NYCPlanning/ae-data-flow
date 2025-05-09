#! /bin/sh

tippecanoe \
    -z20 \
    --projection=EPSG:4326 \
    -o data/convert/capital-project-fill.pmtiles \
    -l capital-project-fill data/convert/capital-project-fill.json \
    --force

tippecanoe \
    -B4 \
    -z20 \
    --projection=EPSG:4326 \
    -o data/convert/capital-project-label.pmtiles \
    -l capital-project-label data/convert/capital-project-label.json \
    --force


tile-join \
    -o data/convert/capital-projects.pmtiles \
    data/convert/capital-project-fill.pmtiles \
    data/convert/capital-project-label.pmtiles \
    --force
