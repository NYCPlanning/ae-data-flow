DROP TABLE IF EXISTS
    policy_area,
    need_group,
    cbbr_agency,
    type,
    need,
    request,
    budget_request,
    CASCADE;

CREATE TABLE IF NOT EXISTS policy_area (
	policy_area text
);

CREATE TABLE IF NOT EXISTS need_group (
	need_group text
);

CREATE TABLE IF NOT EXISTS cbbr_agency (
	agency text
);

CREATE TABLE IF NOT EXISTS TYPE (
	type text
);

CREATE TABLE IF NOT EXISTS need (
	need text
);

CREATE TABLE IF NOT EXISTS request (
	request text
);

CREATE TABLE IF NOT EXISTS budget_request (
    id text,
    tracking_code text,
    borough_code text,
    cd text,
    type text,
    priority text,
    need text,
    request text,
    explanation text,
    location text,
    site_name text,
    address text,
    cross_street_1 text,
	cross_street_2 text,
	intersection_street_1 text,
	intersection_street_2 text,
	supporters_1 text,
	supporters_2 text,
    agency text,
    agency_response text,
    geo_function text,
    geom geometry
);