DROP TABLE IF EXISTS 
	source_borough,
	source_capital_commitment, 
	source_city_council_district,
	source_land_use,
	source_pluto,
	source_zoning_district,
	CASCADE;

CREATE TABLE IF NOT EXISTS source_borough (
	"id" char(1) PRIMARY KEY NOT NULL,
	"title" text,
	"abbr" char(2)
);

CREATE TABLE IF NOT EXISTS source_capital_commitment (
  ccp_version text,
  m_agency text,
  project_id text,
  m_a_proj_id text,
  budget_line text,
  project_type text,
  s_agency_acro text,
  s_agency_name text,
  -- plan_comm_date should be a date but the stored format is text
  plan_comm_date text,
  project_description text,
  commitment_description text,
  commitment_code char(4),
  typ_c char(3),
  typ_c_name text,
  plannedcommit_ccnonexempt numeric,
  plannedcommit_ccexempt numeric,
  plannedcommit_citycost numeric,
  plannedcommit_nccstate numeric,
  plannedcommit_nccfederal numeric,
  plannedcommit_nccother numeric,
  plannedcommit_noncitycost numeric,
  plannedcommit_total numeric
);

CREATE TABLE IF NOT EXISTS source_city_council_district (
	"coundist" text NOT NULL,
	"shape_leng" float,
	"shape_area" float,
	"wkt" geometry(MULTIPOLYGON, 4326)
);

CREATE TABLE IF NOT EXISTS source_land_use (
	"id" char(2) PRIMARY KEY NOT NULL,
	"description" text,
	"color" char(9)
);

CREATE TABLE IF NOT EXISTS source_pluto (
	"bbl" text PRIMARY KEY NOT NULL,
	"borough" char(2) NOT NULL,
	"block" text NOT NULL,
	"lot" text NOT NULL,
	"address" text,
	"land_use" char(2),
	"wkt" geometry(MULTIPOLYGON, 2263)
);

CREATE TABLE IF NOT EXISTS source_zoning_district (
	"zonedist" text NOT NULL,
	"shape_leng" float,
	"shape_area" float,
	"wkt" geometry(MULTIPOLYGON, 4326)
);