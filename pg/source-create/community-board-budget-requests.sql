DROP TABLE IF EXISTS
	source_cbbr_option,
	source_cbbr_export
	CASCADE;

CREATE TABLE IF NOT EXISTS source_cbbr_option (
	"Policy Area" text,
	"Need Group" text,
	"Agency" text,
	"Type" text,
	"Need" text,
	"Request" text
);

CREATE TABLE IF NOT EXISTS source_cbbr_export (
	unique_id text,
	tracking_code text,
	title text,
	borough text,
	borough_code char(1) NOT NULL,
	cd char(2) NOT NULL CHECK (cd SIMILAR TO '[0-9]{2}'),
	commdist char(3) NOT NULL,
	cb_label text,
	type_br char(1) NOT NULL CHECK (type_br IN ('C', 'E')),
	priority integer,
	policy_area text,
	need_group text,
	need text,
	request text,
	explanation text,
	location_specific text,
	site_name text,
	address text,
	street_name text,
	on_street text,
	cross_street_1 text,
	cross_street_2 text,
	intersection_street_1 text,
	intersection_street_2 text,
	supporters_1 text,
	supporters_2 text,
	agency_acronym text,
	agency text,
	agency_category_response text,
	agency_response text,
	geo_function text,
	geom geometry(geometry, 4326)
);