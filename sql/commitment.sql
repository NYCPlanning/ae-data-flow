-- Break into ETL sql file "activate_postgis"
-- Note, some existing data flow files start with this command
-- It is needed across all processes and really should be consolidated to a
-- single file invoked at the start of each process
BEGIN;
	CREATE EXTENSION IF NOT EXISTS postgis;
COMMIT;
-- end "activate_postgis"

-- Break into ETL sql file "commitment_source_tables"
-- Schema for source tables
BEGIN;
	CREATE TABLE commitment_source (
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
	
	CREATE TABLE project_source (
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
	
COMMIT;
-- end "commitment_source_tables"


-- Break into "import_commitment" ETL sql file
-- Populate source tables
BEGIN;
	COPY project_source FROM 'cpdb_projects_23adopt.csv' DELIMITER ',' CSV HEADER;
COMMIT;

BEGIN;
	COPY commitment_source FROM 'cpdb_planned_commitments_23adopt.csv' DELIMITER ',' CSV HEADER;
COMMIT;
-- end "import_commitment"

-- Remove "structure_target_tables" code
-- The role of structuring the tables will be replaced by the target database
-- Sharing its schema with this engine database
-- Structure of target tables
BEGIN;
	CREATE TABLE managing_code (
		id char(3) PRIMARY KEY
	);

	CREATE TABLE agency (
		initials text PRIMARY KEY,
		name text
	);
	
	CREATE TYPE project_category AS ENUM (
		'Fixed Asset',
		'Lump Sum',
		'ITT, Vehicles, and Equipment'
	);
		
	CREATE TABLE project (
		PRIMARY KEY (managing_code, id),
    	managing_code char(3) references managing_code(id),
		id text,
		managing_agency text references agency(initials),
		description text,
		min_date date,
		max_date date,
		category project_category,
		li_ft_m_pnt geometry(multipoint, 2263),
		li_ft_m_poly geometry(multipolygon, 2263),
		mercator_label geometry(point, 3857),
		mercator_fill_m_pnt geometry(multipoint, 3857),
		mercator_fill_m_poly geometry(multipolygon, 3857)
	);

	CREATE TABLE project_checkbook(
		id uuid PRIMARY KEY,
		managing_code char(3),
		project_id text,
		FOREIGN KEY (managing_code, project_id) references project(managing_code, id),
		value numeric
	);

	CREATE TYPE fund_category AS ENUM (
		'city-non-exempt',
		'city-exempt',
		'city-cost',
		'non-city-state',
		'non-city-federal',
		'non-city-other',
		'non-city-cost',
		'total'
	);

	CREATE TYPE project_fund_stage AS ENUM (
		'adopt',
		'allocate',
		'commit',
		'spent'
	);

	CREATE TABLE project_fund (
		id uuid PRIMARY KEY,
		managing_code char(3),
		project_id text,
		FOREIGN KEY (managing_code, project_id) references project(managing_code, id),
		category fund_category,
		stage project_fund_stage,
		value numeric
	);
	
	CREATE TABLE commitment_type (
		code char(4) PRIMARY KEY,
		description text
	);
	
	CREATE TABLE agency_budget (
		code text PRIMARY KEY,
		type text,
		sponsor text references agency(initials)
	);
	
	CREATE TABLE budget_line (
		code text references agency_budget(code),
		id text NOT NULL,
		PRIMARY KEY (code, id)
	);
	
	CREATE TABLE commitment (
		id uuid PRIMARY KEY,
		type char(4) references commitment_type(code),
		planned_date date,
		managing_code char(3) NOT NULL,
		project_id text NOT NULL,
		FOREIGN KEY (managing_code, project_id) references project(managing_code, id),
		budget_line_code text NOT NULL,
		budget_line_id text NOT NULL,
		FOREIGN KEY (budget_line_code, budget_line_id) references budget_line(code, id)
	);
	
	CREATE TABLE commitment_fund (
		id uuid PRIMARY KEY,
		commitment_id uuid references commitment(id),
		category fund_category,
		value numeric
	);

SAVEPOINT target_structure;
-- End "structure_target_tables"

-- Break into ETL sql file "commitment_transform"

-- Move managing codes into managing_code table
INSERT INTO managing_code
SELECT DISTINCT
	m_agency as id
FROM project_source;

-- Move managing agencies from project table into agency table
INSERT INTO agency
SELECT DISTINCT
	m_agency_acro as initials,
	m_agency_name as name
FROM project_source;

-- Move sponsoring agencies from commitment table into agency table
INSERT INTO agency
SELECT DISTINCT 
	s_agency_acro as initials,
	s_agency_name as name
FROM commitment_source
WHERE s_agency_acro NOT IN (SELECT initials FROM agency);

-- Move project source into project target
INSERT INTO project
SELECT 
	m_agency AS managing_code,
	proj_id AS id,
	m_agency_acro AS managing_agency,
	description,
	min_date,
	max_date,
	type_category::project_category AS category
FROM project_source;

-- Move data from project source to project_checkbook
INSERT INTO project_checkbook
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	spent_total_checkbooknyc AS value
FROM project_source;

-- Move data from project source to project fund

-- I know what you're thinking; this is a lot of repeated code.
-- It's tempting to transform the table and use a regex on the column name to try generalizing the logic.
-- However, this goes against the grain for Postgres and introducing python is yet another tool to manage.
-- Once you get beyond the gut check, this code is fine. In fact, it's simple and expressive.
-- Also, as much as there is repeated code, there is non-repeated code that needs to be specified somewhere.
-- Don't spend too much time worrying about it or trying to "fix" it.

-- adopt
INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-non-exempt'::fund_category AS category,
	'adopt'::project_fund_stage AS stage,
	adopt_ccnonexempt AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-exempt'::fund_category AS category,
	'adopt'::project_fund_stage AS stage,
	adopt_ccexempt AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-cost'::fund_category AS category,
	'adopt'::project_fund_stage AS stage,
	adopt_citycost AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-state'::fund_category AS category,
	'adopt'::project_fund_stage AS stage,
	adopt_nccstate AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-federal'::fund_category AS category,
	'adopt'::project_fund_stage AS stage,
	adopt_nccfederal AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-other'::fund_category AS category,
	'adopt'::project_fund_stage AS stage,
	adopt_nccother AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-cost'::fund_category AS category,
	'adopt'::project_fund_stage AS stage,
	adopt_noncitycost AS value
FROM project_source;

-- allocate
INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-non-exempt'::fund_category AS category,
	'allocate'::project_fund_stage AS stage,
	allocate_ccnonexempt AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-exempt'::fund_category AS category,
	'allocate'::project_fund_stage AS stage,
	allocate_ccexempt AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-cost'::fund_category AS category,
	'allocate'::project_fund_stage AS stage,
	allocate_citycost AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-state'::fund_category AS category,
	'allocate'::project_fund_stage AS stage,
	allocate_nccstate AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-federal'::fund_category AS category,
	'allocate'::project_fund_stage AS stage,
	allocate_nccfederal AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-other'::fund_category AS category,
	'allocate'::project_fund_stage AS stage,
	allocate_nccother AS value
FROM project_source;

-- commit
INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-non-exempt'::fund_category AS category,
	'commit'::project_fund_stage AS stage,
	commit_ccnonexempt AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-exempt'::fund_category AS category,
	'commit'::project_fund_stage AS stage,
	commit_ccexempt AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-cost'::fund_category AS category,
	'commit'::project_fund_stage AS stage,
	commit_citycost AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-state'::fund_category AS category,
	'commit'::project_fund_stage AS stage,
	commit_nccstate AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-federal'::fund_category AS category,
	'commit'::project_fund_stage AS stage,
	commit_nccfederal AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-other'::fund_category AS category,
	'commit'::project_fund_stage AS stage,
	commit_nccother AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-cost'::fund_category AS category,
	'commit'::project_fund_stage AS stage,
	commit_noncitycost AS value
FROM project_source;

-- spent
INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-non-exempt'::fund_category AS category,
	'spent'::project_fund_stage AS stage,
	spent_ccnonexempt AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-exempt'::fund_category AS category,
	'spent'::project_fund_stage AS stage,
	spent_ccexempt AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'city-cost'::fund_category AS category,
	'spent'::project_fund_stage AS stage,
	spent_citycost AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-state'::fund_category AS category,
	'spent'::project_fund_stage AS stage,
	spent_nccstate AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-federal'::fund_category AS category,
	'spent'::project_fund_stage AS stage,
	spent_nccfederal AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-other'::fund_category AS category,
	'spent'::project_fund_stage AS stage,
	spent_nccother AS value
FROM project_source;

INSERT INTO project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	'non-city-cost'::fund_category AS category,
	'spent'::project_fund_stage AS stage,
	spent_noncitycost AS value
FROM project_source;

-- Move data from commitment source to commitment_type
INSERT INTO commitment_type
SELECT DISTINCT
	commitment_code AS code,
	commitment_description AS description
FROM commitment_source;

-- Move data from commitment source to agency_budget
INSERT INTO agency_budget
SELECT DISTINCT 
	SPLIT_PART(budget_line, '-', 1) AS code,
	project_type AS type,
	s_agency_acro AS sponsor
FROM commitment_source;

-- Move data from commitment source to budget_line
INSERT INTO budget_line
SELECT DISTINCT 
	SPLIT_PART(budget_line, '-', 1) AS code,
	SPLIT_PART(budget_line, '-', 2) AS id
FROM commitment_source;

-- Provide uuids to commitent source
SELECT gen_random_uuid() as id, *
INTO commitment_source_id
FROM commitment_source;

-- Move data from commitment source id to commitment
INSERT INTO commitment
SELECT 
	id,
	commitment_code AS type,
	TO_DATE(plan_comm_date, 'MM/YY') AS planned_date,
	m_agency AS managing_code,
	project_id,
	SPLIT_PART(budget_line, '-', 1) AS budget_line_code,	
	SPLIT_PART(budget_line, '-', 2) AS budget_line_id
FROM commitment_source_id;

-- Move data from commitment source id to commitment_fund
INSERT INTO commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS commitment_id,
	'city-non-exempt'::fund_category AS category,
	plannedcommit_ccnonexempt AS value
FROM commitment_source_id;

INSERT INTO commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS commitment_id,
	'city-exempt'::fund_category AS category,
	plannedcommit_ccexempt AS value
FROM commitment_source_id;

INSERT INTO commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS commitment_id,
	'non-city-state'::fund_category AS category,
	plannedcommit_nccstate AS value
FROM commitment_source_id;

INSERT INTO commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS commitment_id,
	'non-city-federal'::fund_category AS category,
	plannedcommit_nccfederal AS value
FROM commitment_source_id;

INSERT INTO commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS commitment_id,
	'non-city-other'::fund_category AS category,
	plannedcommit_nccother AS value
FROM commitment_source_id;

INSERT INTO commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS commitment_id,
	'non-city-cost'::fund_category AS category,
	plannedcommit_noncitycost AS value
FROM commitment_source_id;

INSERT INTO commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS commitment_id,
	'total'::fund_category AS category,
	plannedcommit_total AS value
FROM commitment_source_id;

-- 
WITH project_spatial AS (
	SELECT 
		COALESCE(project_polygon.magency,project_point.magency) AS managing_code,
		COALESCE(project_polygon.projectid, project_point.projectid) id,
		project_polygon.geom AS polygon,
		project_point.geom AS point
	FROM project_polygon
	FULL OUTER JOIN project_point
		ON project_polygon.magency = project_point.magency AND 
			project_polygon.projectid = project_point.projectid
		)
	UPDATE project
-- 		Need to transform to 2263 because it is imported as 6539
		SET li_ft_m_pnt = ST_Transform(project_spatial.point, 2263),
			li_ft_m_poly = ST_Transform(project_spatial.polygon, 2263),
			mercator_label = CASE 
								WHEN project_spatial.point IS NOT NULL THEN ST_Transform(ST_PointOnSurface(project_spatial.point), 3857)
								WHEN project_spatial.polygon IS NOT NULL THEN ST_Transform((ST_MaximumInscribedCircle(project_spatial.polygon)).center, 3857)
							END,
			mercator_fill_m_pnt = ST_Transform(project_spatial.point, 3857),
			mercator_fill_m_poly = ST_Transform(project_spatial.polygon, 3857)
	FROM project_spatial
	WHERE project_spatial.managing_code = project.managing_code AND
		project_spatial.id = project.id;
-- End "commitment_transform"

BEGIN;
	CREATE TABLE city_council_district (
	id text PRIMARY KEY,
	li_ft geometry(MultiPolygon, 2263),
	mercator_fill geometry(MultiPolygon, 3857),
	mercator_label geometry(Point, 3857)
	);
COMMIT;

BEGIN;
	INSERT INTO city_council_district
	SELECT
		coundist AS id,
		ST_Transform(geom, 2263) AS li_ft,
		ST_Transform(geom, 3857) AS mercator_fill,
		ST_Transform((ST_MaximumInscribedCircle(geom)).center, 3857) AS mercator_label
	FROM city_council_districts_source
COMMIT;

BEGIN;
	CREATE TABLE borough (
	id char(1) PRIMARY KEY,
	name text,
	li_ft geometry(MultiPolygon, 2263),
	mercator_fill geometry(MultiPolygon, 3857),
	mercator_label geometry(Point, 3857)
	);
COMMIT;

BEGIN;
	INSERT INTO borough
	SELECT
		borocode AS id,
		boroname AS name,
		ST_Transform(geom, 2263) AS li_ft,
		ST_Transform(geom, 3857) AS mercator_fill,
		ST_Transform((ST_MaximumInscribedCircle(geom)).center, 3857) AS mercator_label
	FROM borough_source
COMMIT;

BEGIN;
	CREATE TABLE community_district (
	borough_id char(1) references borough(id),
	id char(2),
	PRIMARY KEY (borough_id, id),
	li_ft geometry(MultiPolygon, 2263),
	mercator_fill geometry(MultiPolygon, 3857),
	mercator_label geometry(Point, 3857)
	)
COMMIT;

BEGIN;
	INSERT INTO community_district
	SELECT
		SUBSTRING(borocd::text, 1, 1) AS borough_id,
		SUBSTRING(borocd::text, 2, 3) AS id,
		ST_Transform(geom, 2263) AS li_ft,
		ST_Transform(geom, 3857) AS mercator_fill,
		ST_Transform((ST_MaximumInscribedCircle(geom)).center, 3857) AS mercator_label
	FROM community_districts_source
COMMIT;