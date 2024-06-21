-- Tax lots
DROP TABLE IF EXISTS source_pluto;
DROP INDEX IF EXISTS pluto_geom_idx;
CREATE TABLE IF NOT EXISTS "source_pluto" (
	"bbl" text PRIMARY KEY NOT NULL,
	"borough" char(2) NOT NULL,
	"block" text NOT NULL,
	"lot" text NOT NULL,
	"address" text,
	"land_use" char(2),
	"wkt" geometry(MULTIPOLYGON, 2263)
);
CREATE INDEX pluto_geom_idx
  ON source_pluto
  USING GIST (wkt);

\COPY source_pluto ("wkt", "borough", "block", "lot", "address", "land_use", "bbl") FROM '.data/pluto.csv' DELIMITER ',' CSV HEADER;

-- Zoning Districts
DROP TABLE IF EXISTS source_zoning_districts;
DROP INDEX IF EXISTS zoning_districts_geom_idx;
CREATE TABLE IF NOT EXISTS "source_zoning_districts" (
	"zonedist" text NOT NULL,
	"shape_leng" float,
	"shape_area" float,
	"wkt" geometry(MULTIPOLYGON, 4326)
);
CREATE INDEX zoning_districts_geom_idx
  ON source_zoning_districts
  USING GIST (wkt);

\COPY source_zoning_districts ("wkt", "zonedist", "shape_leng", "shape_area") FROM '.data/zoning_districts.csv' DELIMITER ',' CSV HEADER;

-- Capital commitments
CREATE TABLE IF NOT EXISTS capital_commitment_source (
  ccp_version text,
  m_agency text,
  project_id text,
  m_a_proj_id text,
  budget_line text,
  -- plan_comm_date should be a date but the stored format is text
  project_type text,
  s_agency_acro text,
  s_agency_name text,
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

\COPY capital_commitment_source FROM  '.data/cpdb_planned_commitments.csv' DELIMITER ',' CSV HEADER;

-- Capital projects
CREATE TABLE IF NOT EXISTS  capital_project_source (
  ccp_version text,
  m_a_proj_id text,
  m_agency_acro text,
  m_agency char(3),
  m_agency_name text,
  description text,
  proj_id text,
  min_date date,
  max_date date,
  type_category text,
  plannedcommit_ccnonexempt numeric,
  plannedcommit_ccexempt numeric,
  plannedcommit_citycost numeric,
  plannedcommit_nccstate numeric,
  plannedcommit_nccfederal numeric,
  plannedcommit_nccother numeric,
  plannedcommit_noncitycost numeric,
  plannedcommit_total numeric,
  adopt_ccnonexempt numeric,
  adopt_ccexempt numeric,
  adopt_citycost numeric,
  adopt_nccstate numeric,
  adopt_nccfederal numeric,
  adopt_nccother numeric,
  adopt_noncitycost numeric,
  adopt_total numeric,
  allocate_ccnonexempt numeric,
  allocate_ccexempt numeric,
  allocate_citycost numeric,
  allocate_nccstate numeric,
  allocate_nccfederal numeric,
  allocate_nccother numeric,
  allocate_noncitycost numeric,
  allocate_total numeric,
  commit_ccnonexempt numeric,
  commit_ccexempt numeric,
  commit_citycost numeric,
  commit_nccstate numeric,
  commit_nccfederal numeric,
  commit_nccother numeric,
  commit_noncitycost numeric,
  commit_total numeric,
  spent_ccnonexempt numeric,
  spent_ccexempt numeric,
  spent_citycost numeric,
  spent_nccstate numeric,
  spent_nccfederal numeric,
  spent_nccother numeric,
  spent_noncitycost numeric,
  spent_total numeric,
  spent_total_checkbooknyc numeric
);
	
\COPY capital_project_source FROM '.data/cpdb_projects.csv' DELIMITER ',' CSV HEADER;

