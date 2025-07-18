DROP TABLE IF EXISTS
	source_community_board_budget_request_options
	CASCADE;

CREATE TABLE IF NOT EXISTS source_community_board_budget_request_options (
	"Policy Area" text,
	"Need Group" text,
	"Agency" text,
	"Type" text,
	"Need" text,
	"Request" text
);
