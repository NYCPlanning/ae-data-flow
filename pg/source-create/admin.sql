DROP TABLE IF EXISTS 
	source_city_council_district,
	source_community_district
	CASCADE;

CREATE TABLE IF NOT EXISTS source_city_council_district (
	coundist text PRIMARY KEY CHECK (coundist SIMILAR TO '[0-9]{1,2}'),
	shape_leng float,
	shape_area float,
	wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);

CREATE TABLE IF NOT EXISTS source_community_district (
	borocd char(3) PRIMARY KEY CHECK (borocd SIMILAR TO '[1-9][0-9]{2}'),
	shape_leng float,
	shape_area float,
	wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);
