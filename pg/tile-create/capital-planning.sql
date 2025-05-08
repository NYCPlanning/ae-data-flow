DROP TABLE IF EXISTS
	tile_capital_project
	CASCADE;

CREATE TABLE IF NOT EXISTS tile_capital_project (
	managing_code_capital_project_id text,
	managing_agency text,
	commitments_total double precision,
	agency_budgets json,
	fill geometry,
	label geometry(POINT, 4326) NOT NULL
);
