DROP TABLE IF EXISTS
    community_board_budget_request
    CASCADE;

CREATE TABLE IF NOT EXISTS community_board_budget_request (
    tracking_code text PRIMARY KEY CHECK (tracking_code SIMILAR TO '[0-9]{9}[A-Z]{1,2}'),
	borough_id char(1) NOT NULL, -- TODO: Relationship to borough table
	community_district_id char(2) NOT NULL,
	type text NOT NULL CHECK (type IN ('CAPITAL', 'EXPENSE'))
);
