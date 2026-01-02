DROP TABLE IF EXISTS
	tile_capital_project
	CASCADE;

CREATE TABLE IF NOT EXISTS tile_capital_project (
	"managingCodeCapitalProjectId" text,
	"managingAgency" text,
	"commitmentsTotal" double precision,
	"agencyBudgets" json,
	"fill" geography(GEOMETRY, 4326) NOT NULL,
	"label" geography(POINT, 4326) NOT NULL
);
