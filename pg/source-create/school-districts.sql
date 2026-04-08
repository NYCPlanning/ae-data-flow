DROP TABLE IF EXISTS
    source_school_district
    CASCADE;

CREATE TABLE IF NOT EXISTS source_school_district (
    schooldist integer,
    shape_leng float,
    shape_area float,
    geometry geometry(MULTIPOLYGON, 4326) 
);