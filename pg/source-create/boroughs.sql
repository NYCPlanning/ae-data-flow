DROP TABLE IF EXISTS 
	source_borough
	CASCADE;

CREATE TABLE IF NOT EXISTS source_borough (
    boro_code char(1) PRIMARY KEY NOT NULL CHECK (boro_code SIMILAR TO '[1-9]'),
    boro_name text,
    shape_leng float,
	shape_area float,
    wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);
