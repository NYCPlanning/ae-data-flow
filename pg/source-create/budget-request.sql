DROP TABLE IF EXISTS 
	source_budget_request
	CASCADE;

CREATE TABLE IF NOT EXISTS source_budget_request (
	unique_id text,
	tracking_code text,
	borough text,
	borough_code char(1),
	cd char(2),
	commdist char(3),
	cb_label text,
	type_br char(1),
	type_description text,
	priority text,
	need text,
	request text,
	explanation text,
	site_location text,
	site_name text,
	site_address text,
	street_name text,
	street_cross_1 text,
	street_cross_2 text,
	supporters_1 text,
	supporters_2 text,
	parent_tracking_code text,
	agency_acro text,
	agency text,
	agency_category_response text,
	agency_response text,
	geo_function text,
	-- what projection is the geom in?
	geom text
)