DROP TABLE IF EXISTS 
	source_land_use,
	source_pluto,
	source_zoning_district,
	source_zoning_district_class
	CASCADE;

CREATE TABLE IF NOT EXISTS source_land_use (
	id char(2) PRIMARY KEY NOT NULL CHECK (id SIMILAR TO '[0-9]{2}'),
	description text,
	color char(9) NOT NULL CHECK (color SIMILAR TO '#([A-Fa-f0-9]{8})')
);

CREATE TABLE IF NOT EXISTS source_pluto (
	bbl text PRIMARY KEY NOT NULL CHECK (bbl SIMILAR TO '[0-9]{10}\.00000000'),
	borough char(2) NOT NULL,
	block text NOT NULL CHECK (block SIMILAR TO '[0-9]{1,5}'),
	lot text NOT NULL CHECK (lot SIMILAR TO '[0-9]{1,4}'),
	address text,
	land_use char(2),
	wkt geometry(MULTIPOLYGON, 2263) NOT NULL
);

CREATE TABLE IF NOT EXISTS source_zoning_district (
	zonedist text NOT NULL,
	shape_leng float,
	shape_area float,
	wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);

CREATE TABLE IF NOT EXISTS source_zoning_district_class (
	id text PRIMARY KEY CHECK (id SIMILAR TO '[A-Z][0-9]+'),
	category category NOT NULL,
	description text,
	url text,
	color char(9) NOT NULL CHECK (color SIMILAR TO '#([A-Fa-f0-9]{8})')
)
