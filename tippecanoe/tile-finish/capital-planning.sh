#! /bin/sh

tippecanoe \
    -z20 \
    --projection=EPSG:4326 \
    -o tile-finish/interim/capital-project-fill.pmtiles \
    -l capital-project-fill data/tiles/extracted/capital-planning-fill.json \
    --force

tippecanoe \
    -B4 \
    -z20 \
    --projection=EPSG:4326 \
    -o tile-finish/interim/capital-project-label.pmtiles \
    -l capital-project-label data/tiles/extracted/capital-planning-label.json \
    --force

tile-join \
    -o data/tiles/finished/capital-projects.pmtiles \
    tile-finish/interim/capital-project-fill.pmtiles \
    tile-finish/interim/capital-project-label.pmtiles \
    --force
