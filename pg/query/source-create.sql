DROP TABLE IF EXISTS 
	source_borough,
	source_capital_commitment, 
	source_capital_project,
	source_capital_project_m_poly, 
	source_capital_project_m_pnt,
	source_city_council_district,
  source_community_district,
	source_land_use,
	source_pluto,
	source_zoning_district,
	source_zoning_district_class
	CASCADE;

CREATE TABLE IF NOT EXISTS source_borough (
	id char(1) PRIMARY KEY NOT NULL CHECK (id SIMILAR TO '[1-9]'),
	title text,
	abbr char(2)
);

CREATE TABLE IF NOT EXISTS source_capital_commitment (
  ccp_version text,
  m_agency char(3) NOT NULL CHECK (m_agency SIMILAR TO '[0-9]{3}'),
  project_id text NOT NULL,
  m_a_proj_id text,
  budget_line text,
  project_type text,
  s_agency_acro text,
  s_agency_name text,
  -- plan_comm_date should be a date but the stored format is text
  plan_comm_date text,
  project_description text,
  commitment_description text,
  commitment_code char(4) NOT NULL,
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

CREATE TABLE IF NOT EXISTS  source_capital_project (
  ccp_version text,
  m_a_proj_id text,
  m_agency_acro text,
  m_agency char(3) NOT NULL CHECK (m_agency SIMILAR TO '[0-9]{3}'),
  m_agency_name text,
  description text,
  proj_id text NOT NULL,
  min_date date,
  max_date date,
  -- TODO: check that it satisfies the capital_project_category enum,
  -- once the enum is fixed
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

CREATE TABLE IF NOT EXISTS source_capital_project_m_poly (
	ccpversion text,
	maprojid text,
	magency text,
	magencyacr text,
	projectid text,
	descriptio text,
	typecatego text,
	geomsource text,
	dataname text,
	datasource text,
	datadate text,
	wkt geometry(MULTIPOLYGON, 4326)
);

CREATE TABLE IF NOT EXISTS source_capital_project_m_pnt (
	ccpversion text,
	maprojid text,
	magency text,
	magencyacr text,
	projectid text,
	descriptio text,
	typecatego text,
	geomsource text,
	dataname text,
	datasource text,
	datadate text,
	wkt geometry(MULTIPOINT, 4326)
);

CREATE TABLE IF NOT EXISTS source_city_council_district (
	coundist text PRIMARY KEY CHECK (coundist SIMILAR TO '[0-9]{1,2}'),
	shape_leng float,
	shape_area float,
	wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);

CREATE TABLE IF NOT EXISTS source_community_district (
	borocd char(3) PRIMARY KEY CHECK (borocd SIMILAR TO '[1-9][0-9]{2}'),
	shape_leng float,
	shape_area float,
	wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);

CREATE TABLE IF NOT EXISTS source_land_use (
	id char(2) PRIMARY KEY NOT NULL CHECK (id SIMILAR TO '[0-9]{2}'),
	description text,
	color char(9) NOT NULL CHECK (color SIMILAR TO '#([A-Fa-f0-9]{8})')
);

CREATE TABLE IF NOT EXISTS source_pluto (
	bbl text PRIMARY KEY NOT NULL CHECK (bbl SIMILAR TO '[0-9]{10}\.00000000'),
	borough char(2) NOT NULL,
	block text NOT NULL CHECK (block SIMILAR TO '[0-9]{1,5}'),
	lot text NOT NULL CHECK (lot SIMILAR TO '[0-9]{1,4}'),
	address text,
	land_use char(2),
	wkt geometry(MULTIPOLYGON, 2263) NOT NULL
);

CREATE TABLE IF NOT EXISTS source_zoning_district (
	zonedist text NOT NULL,
	shape_leng float,
	shape_area float,
	wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);

CREATE TABLE IF NOT EXISTS source_zoning_district_class (
	id text PRIMARY KEY CHECK (id SIMILAR TO '[A-Z][0-9]+'),
	category category NOT NULL,
	description text,
	url text,
	color char(9) NOT NULL CHECK (color SIMILAR TO '#([A-Fa-f0-9]{8})')
)
