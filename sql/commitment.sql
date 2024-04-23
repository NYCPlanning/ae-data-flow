-- Populate source tables
BEGIN;
	COPY project_source FROM 'cpdb_projects_23adopt.csv' DELIMITER ',' CSV HEADER;
COMMIT;

BEGIN;
	COPY commitment_source FROM 'cpdb_planned_commitments_23adopt.csv' DELIMITER ',' CSV HEADER;
COMMIT;

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

-- Move managing codes into managing_code table
BEGIN;
INSERT INTO managing_code
SELECT DISTINCT
	m_agency as id
FROM project_source;
COMMIT;

-- MOVE managing agencies from project table into agency table
BEGIN;
INSERT INTO agency
SELECT DISTINCT 
-- 	CASE WHEN m_agency_acro = 'UK' THEN CONCAT(m_agency_acro, m_agency) ELSE m_agency_acro END as initials,
	m_agency_acro as initials,
	m_agency_name as name
FROM project_source
COMMIT;

-- Move sponsoring agencies from commitment table into agency table
BEGIN;
INSERT INTO agency
SELECT DISTINCT 
	s_agency_acro as initials,
	s_agency_name as name
FROM commitment_source
WHERE s_agency_acro NOT IN (SELECT initials FROM agency)
COMMIT;

-- Move managing initials and code into many to many table
BEGIN;
INSERT INTO agency_managing_code
SELECT DISTINCT
	m_agency_acro as agency_initials,
	m_agency as managing_code_id
FROM project_source;
COMMIT;

-- Structure of target tables
BEGIN;
	CREATE TABLE managing_code (
		id char(3) PRIMARY KEY
	);
	
	CREATE TABLE agency (
		initials text PRIMARY KEY,
		name text
	);
	
 -- likely unnecessary as a table because the project needs to capture both its managing code and its managing agency 
	CREATE TABLE agency_managing_code (
		agency_initials text references agency(initials),
		managing_code_id char(3) references managing_code(id)
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
	
	CREATE TABLE capital_commitment_plan(
		version text PRIMARY KEY
	);
	
	CREATE TABLE ten_year_plan_category (
		code char(3) PRIMARY KEY,
		name text
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
		capital_commitment_plan text references capital_commitment_plan(version),
		type char(4) references commitment_type(code),
		planned_date date,
		managing_code char(3) NOT NULL,
		project_id text NOT NULL,
		FOREIGN KEY (managing_code, project_id) references project(managing_code, id),
		budget_line_code text NOT NULL,
		budget_line_id text NOT NULL,
		FOREIGN KEY (budget_line_code, budget_line_id) references budget_line(code, id),
		ten_year_plan_category_code char(3) references ten_year_plan_category(code),
		planned_city_non_exempt numeric,
		planned_city_exempt numeric,
		planned_city_total numeric,
		planned_state numeric,
		planned_federal numeric,
		planned_other numeric,
		planned_non_city numeric,
		planned_total numeric
	);
	
COMMIT;
