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
	
 -- likely unnecessary as a table because the project table already captures both its managing code and its managing agency 
	-- CREATE TABLE agency_managing_code (
	-- 	agency_initials text references agency(initials),
	-- 	managing_code_id char(3) references managing_code(id)
	-- );
	
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
		adopt_city_non_exempt numeric,
		adopt_city_exempt numeric,
		adopt_city_total numeric,
		adopt_state numeric,
		adopt_federal numeric,
		adopt_other numeric,
		adopt_non_city numeric,
		adopt_total numeric,
		allocate_city_non_exempt numeric,
		allocate_city_exempt numeric,
		allocate_city_total numeric,
		allocate_state numeric,
		allocate_federal numeric,
		allocate_other numeric,
		allocate_non_city numeric,
		allocate_total numeric,
		commit_city_non_exempt numeric,
		commit_city_exempt numeric,
		commit_city_total numeric,
		commit_state numeric,
		commit_federal numeric,
		commit_other numeric,
		commit_non_city numeric,
		commit_total numeric,
		spent_city_non_exempt numeric,
		spent_city_exempt numeric,
		spent_city_total numeric,
		spent_state numeric,
		spent_federal numeric,
		spent_other numeric,
		spent_non_city numeric,
		spent_total numeric,
		checkbook_nyc numeric		
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
		FOREIGN KEY (ten_year_plan_code, ten_year_plan_name) references ten_year_plan(code, name),
		planned_city_non_exempt numeric,
		planned_city_exempt numeric,
		planned_city_total numeric,
		planned_state numeric,
		planned_federal numeric,
		planned_other numeric,
		planned_non_city numeric,
		planned_total numeric
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

-- Move managing initials and code into many to many table
-- BEGIN;
-- INSERT INTO agency_managing_code
-- SELECT DISTINCT
-- 	m_agency_acro as agency_initials,
-- 	m_agency as managing_code_id
-- FROM project_source;
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
	type_category::project_category AS category,
	adopt_ccnonexempt AS adopt_city_non_exempt,
	adopt_ccexempt AS adopt_city_exempt,
	adopt_citycost AS adopt_city_total,
	-- adopt_non_city_state
	adopt_nccstate AS adopt_state,
	-- adopt_non_city_federal
	adopt_nccfederal AS adopt_federal,
	-- adopt_non_city_other
	adopt_nccother AS adopt_other,
	-- adopt_non_city_total,
	adopt_noncitycost AS adopt_non_city,
	adopt_total,
	allocate_ccnonexempt AS allocate_city_non_exemempt,
	allocate_ccexempt AS allocate_city_exempt,
	allocate_citycost AS allocate_city_total,
	allocate_nccstate AS allocate_state,
	allocate_nccfederal AS allocate_federal,
	allocate_nccother AS allocate_other,
	allocate_noncitycost AS allocate_non_city,
	allocate_total,
	commit_ccnonexempt AS commit_city_non_exemempt,
	commit_ccexempt AS commit_city_exempt,
	commit_citycost AS commit_city_total,
	commit_nccstate AS commit_state,
	commit_nccfederal AS commit_federal,
	commit_nccother AS commit_other,
	commit_noncitycost AS commit_non_city,
	commit_total,
	spent_ccnonexempt AS spent_city_non_exemempt,
	spent_ccexempt AS spent_city_exempt,
	spent_citycost AS spent_city_total,
	spent_nccstate AS spent_state,
	spent_nccfederal AS spent_federal,
	spent_nccother AS spent_other,
	spent_noncitycost AS spent_non_city,
	spent_total
FROM project_source;
SAVEPOINT populate_project;

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

-- Move data from commitment source to commitment
ROLLBACK TO SAVEPOINT populate_budget_line;

SELECT * FROM commitment;
SELECT * FROM project;
INSERT INTO commitment
SELECT 
	gen_random_uuid() as id,
	ccp_version AS capital_commitment_plan,
	commitment_code AS type,
	TO_DATE(plan_comm_date, 'MM/YY') AS planned_date,
	m_agency AS managing_code,
	project_id,
	SPLIT_PART(budget_line, '-', 1) AS budget_line_code,	
	SPLIT_PART(budget_line, '-', 2) AS budget_line_id,
	typ_c AS ten_year_plan_code,
	typ_c_name AS ten_year_plan_name,
	plannedcommit_ccnonexempt AS planned_city_non_exempt,
	plannedcommit_ccexempt AS planned_city_exempt,
	plannedcommit_citycost AS planned_city_total,
	plannedcommit_nccstate AS planned_state,
	plannedcommit_nccfederal AS planned_federal,
	plannedcommit_nccother AS planned_other,
	plannedcommit_noncitycost AS planned_non_city,
	plannedcommit_total AS planned_total
FROM commitment_source;
SAVEPOINT populate_commitment;

COMMIT;
