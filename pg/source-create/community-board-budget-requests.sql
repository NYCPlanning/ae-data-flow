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
	"unique_id" text,
	"tracking_code" text,
	"borough" text,
	"borough_code" text,
	"cd" text,
	"commdist" text,
	"cb_label" text,
	"type_br" text,
	"priority" text,
	"need" text,
	"request" text,
	"explanation" text,
	"location_specific" text,
	"site_name" text,
	"address" text,
	"street_name" text,
	"on_street" text,
	"cross_street_1" text,
	"cross_street_2" text,
	"intersection_street_1" text,
	"intersection_street_2" text,
	"supporters_1" text,
	"supporters_2" text,
	"agency_acronym" text,
	"agency" text,
	"agency_cateogry_response" text,
	"agency_response" text,
	"geo_function" text,
	"geom" text
);