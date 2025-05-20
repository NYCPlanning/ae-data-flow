DROP TABLE IF EXISTS
	source_community_board_budget_request
	CASCADE;

CREATE TABLE IF NOT EXISTS source_community_board_budget_request (
	unique_id text,
	tracking_code text,
	borough text,
	borough_code char(1),
	cd text,
	commdist char(3),
	cb_label char(5),
	type_br char(1),
	priority smallint,
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
	geom geography
);
