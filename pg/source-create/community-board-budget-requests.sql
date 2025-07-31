DROP TABLE IF EXISTS
	source_cbbr_option
	CASCADE;

CREATE TABLE IF NOT EXISTS source_cbbr_option (
	"Policy Area" text,
	"Need Group" text,
	"Agency" text,
	"Type" text,
	"Need" text,
	"Request" text
);
