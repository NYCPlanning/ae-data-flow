DROP TABLE IF EXISTS
	source_borough
	CASCADE;

CREATE TABLE IF NOT EXISTS source_borough (
	borocode char(1) PRIMARY KEY NOT NULL CHECK (borocode SIMILAR TO '[1-9]'),
	boroname text NOT NULL,
	shape_leng float,
	shape_area float,
	wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);
