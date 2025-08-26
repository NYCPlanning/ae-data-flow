DROP TABLE IF EXISTS
	managing_code,
    agency,
    borough,
    community_district,
    cbbr_policy_area,
    cbbr_need_group,
    cbbr_need,
    cbbr_request,
    cbbr_option_cascade,
    community_board_budget_request,
    agency_response 
CASCADE;

CREATE TABLE IF NOT EXISTS community_board_budget_request (
    "id" text NOT NULL,
    "tracking_code" text NOT NULL,
    "borough_id" char(1) NOT NULL,
    "community_district_id" char(2) NOT NULL,
    "agency" text,
    "managing_code" char(3),
    "agency_category_response" text,
    "agency_response" text,
    "type" char(1) NOT NULL,
    "priority" integer NOT NULL,
    "need" text,
    "request" text,
    "explanation" text,
    "is_location_specific" boolean,
    "geom" geometry(geometry, 4326)
);

CREATE TABLE IF NOT EXISTS agency_response (
    "id" char(1) PRIMARY KEY NOT NULL,
    "description" text NOT NULL
);