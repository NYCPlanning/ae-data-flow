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

-- Populate source tables
BEGIN;
	COPY project_source FROM 'cpdb_projects_23adopt.csv' DELIMITER ',' CSV HEADER;
COMMIT;

BEGIN;
	COPY commitment_source FROM 'cpdb_planned_commitments_23adopt.csv' DELIMITER ',' CSV HEADER;
COMMIT;

-- Structure of target tables
-- Right now, we are using data as primary keys. We should evaluate when they should be replaced with separate ids
BEGIN;
	CREATE TABLE managing_code (
		id char(3) PRIMARY KEY
	);

	-- Should likely create an id distinct from initials
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
		category project_category		
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

	-- Should likely create an id separate from version
	CREATE TABLE capital_commitment_plan(
		version text PRIMARY KEY
	);

	-- Should likely create an id separate from version
	CREATE TABLE ten_year_plan (
		code char(3),
		name text,
		PRIMARY KEY (code, name)
	);
	
	-- Should likely create an id separate from version
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
		capital_commitment_plan text references capital_commitment_plan(version),
		type char(4) references commitment_type(code),
		planned_date date,
		managing_code char(3) NOT NULL,
		project_id text NOT NULL,
		FOREIGN KEY (managing_code, project_id) references project(managing_code, id),
		budget_line_code text NOT NULL,
		budget_line_id text NOT NULL,
		FOREIGN KEY (budget_line_code, budget_line_id) references budget_line(code, id),
		ten_year_plan_code char(3),
		ten_year_plan_name text,
		FOREIGN KEY (ten_year_plan_code, ten_year_plan_name) references ten_year_plan(code, name)
	);
	
	CREATE TABLE commitment_fund (
		id uuid PRIMARY KEY,
		commitment_id uuid references commitment(id),
		category fund_category,
		value numeric
	);

-- COMMIT;
SAVEPOINT target_structure;

-- Move managing codes into managing_code table
-- BEGIN;
-- SELECT * FROM managing_code;
INSERT INTO managing_code
SELECT DISTINCT
	m_agency as id
FROM project_source;
SAVEPOINT populate_managing_code;
-- COMMIT;

-- MOVE managing agencies from project table into agency table
-- BEGIN;
-- SELECT * FROM agency;
INSERT INTO agency
SELECT DISTINCT 
-- 	CASE WHEN m_agency_acro = 'UK' THEN CONCAT(m_agency_acro, m_agency) ELSE m_agency_acro END as initials,
	m_agency_acro as initials,
	m_agency_name as name
FROM project_source;
SAVEPOINT populate_agency;
-- COMMIT;

-- Move sponsoring agencies from commitment table into agency table
-- BEGIN;
-- SELECT * FROM agency;
INSERT INTO agency
SELECT DISTINCT 
	s_agency_acro as initials,
	s_agency_name as name
FROM commitment_source
WHERE s_agency_acro NOT IN (SELECT initials FROM agency);
SAVEPOINT populate_agency_sponsors;
-- COMMIT;

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
SAVEPOINT populate_project;

-- Move data from project source to project_checkbook
INSERT INTO project_checkbook
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS project_id,
	spent_total_checkbooknyc AS value
FROM project_source;

SAVEPOINT populate_project_checkbook;

-- Move data from project source to project fund

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

SAVEPOINT populate_project_fund;

-- Move data from commitment source to captial commitment plan
INSERT INTO capital_commitment_plan
SELECT DISTINCT ccp_version FROM commitment_source;
SAVEPOINT populate_capital_commitment_plan;

-- Move data from commitment source to ten_year_plan
INSERT INTO ten_year_plan
SELECT DISTINCT typ_c AS code, typ_c_name AS name FROM commitment_source;
SAVEPOINT populate_ten_year_plan;

-- Move data from commitment source to commitment_type
INSERT INTO commitment_type
SELECT DISTINCT
	commitment_code AS code,
	commitment_description AS description
FROM commitment_source;
SAVEPOINT populate_commitment_type;

-- Move data from commitment source to agency_budget
INSERT INTO agency_budget
SELECT DISTINCT 
	SPLIT_PART(budget_line, '-', 1) AS code,
	project_type AS type,
	s_agency_acro AS sponsor
FROM commitment_source;
SAVEPOINT populate_agency_budget;

-- Move data from commitment source to budget_line
INSERT INTO budget_line
SELECT DISTINCT 
	SPLIT_PART(budget_line, '-', 1) AS code,
	SPLIT_PART(budget_line, '-', 2) AS id
FROM commitment_source;
SAVEPOINT populate_budget_line;

-- Provide uuids to commitent source
SELECT gen_random_uuid() as id, *
INTO commitment_source_id
FROM commitment_source;
SAVEPOINT populate_commitment_source_id;

-- Move data from commitment source id to commitment
INSERT INTO commitment
SELECT 
	id,
	ccp_version AS capital_commitment_plan,
	commitment_code AS type,
	TO_DATE(plan_comm_date, 'MM/YY') AS planned_date,
	m_agency AS managing_code,
	project_id,
	SPLIT_PART(budget_line, '-', 1) AS budget_line_code,	
	SPLIT_PART(budget_line, '-', 2) AS budget_line_id,
	typ_c AS ten_year_plan_code,
	typ_c_name AS ten_year_plan_name
FROM commitment_source_id;
SAVEPOINT populate_commitment;

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
SAVEPOINT populate_commitment_fund;

COMMIT;
