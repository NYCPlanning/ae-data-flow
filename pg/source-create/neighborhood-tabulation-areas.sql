DROP TABLE IF EXISTS
    source_neighborhood_tabulation_areas_2010,
    source_neighborhood_tabulation_areas_2020,
    CASCADE;

CREATE TABLE IF NOT EXISTS source_neighborhood_tabulation_area_2010 (
    borough_code char(1),
    borough_name text,
    county_fips text,
    nta_code text,
    nta_name text,
    shape_leng float,
    shape_area float,
    wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);

CREATE TABLE IF NOT EXISTS source_neighborhood_tabulation_area_2020 (
    borough_code char(1),
    borough_name text,
    county_fips text,
    nta_2020 text,
    nta_name text,
    nta_abbrev text,
    nta_type text,
    cdta_2020 text,
    cdta_name text,
    shape_leng float,
    shape_area float,
    wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);