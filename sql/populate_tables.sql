\COPY borough ("id", "title", "abbr") FROM './borough.csv' DELIMITER ',' CSV HEADER;

\COPY land_use ("id", "description", "color") FROM './land_use.csv' DELIMITER ',' CSV HEADER;

INSERT INTO tax_lot
SELECT
	SUBSTRING(bbl, 1, 10) as bbl,
	borough.id as borough_id,
	block,
	lot,
	address,
	land_use as land_use_id,
	ST_Transform(wkt, 4326) as wgs84,
	wkt as li_ft
FROM source_pluto
INNER JOIN borough ON source_pluto.borough=borough.abbr;

INSERT INTO zoning_district
SELECT
    GEN_RANDOM_UUID() AS id,
    zonedist AS label,
    wkt as wgs84,
		ST_Transform(wkt, 2263) as li_ft
FROM source_zoning_districts
WHERE
    zonedist NOT IN ('PARK', 'BALL FIELD', 'PUBLIC PLACE', 'PLAYGROUND', 'BPC', '')
    AND ST_GEOMETRYTYPE(wkt) = 'ST_MultiPolygon';

\COPY zoning_district_class ( "id", "category", "description", "url", "color" ) FROM './zoning_district_class.csv' DELIMITER ',' CSV HEADER;

INSERT INTO zoning_district_zoning_district_class
WITH split_zones AS (
    SELECT
        id,
        UNNEST(STRING_TO_ARRAY(label, '/')) AS individual_zoning_district
    FROM zoning_district
)
SELECT
    id AS zoning_district_id,
    (REGEXP_MATCH(individual_zoning_district, '^(\w\d+)(?:[^\d].*)?$'))[1] AS zoning_district_class_id
FROM split_zones;

-- Commitment transform
INSERT INTO managing_code
SELECT DISTINCT
	m_agency as id
FROM capital_project_source;

-- Move managing agencies from project table into agency table
INSERT INTO agency
SELECT DISTINCT
	m_agency_acro as initials,
	m_agency_name as name
FROM capital_project_source;

-- Move sponsoring agencies from commitment table into agency table
INSERT INTO agency
SELECT DISTINCT 
	s_agency_acro as initials,
	s_agency_name as name
FROM capital_commitment_source
WHERE s_agency_acro NOT IN (SELECT initials FROM agency);

-- Move project source into project target
INSERT INTO capital_project
SELECT 
	m_agency AS managing_code,
	proj_id AS id,
	m_agency_acro AS managing_agency,
	description,
	min_date,
	max_date,
  -- The enum in the API database drops the oxford comma
  -- This was unintential but the simplest way to rectify
  -- the data source with the API database is to coerce the
  -- source value to drop the oxform comma
  CASE 
	 WHEN type_category = 'Fixed Asset' OR
	 	type_category = 'Fixed Asset' OR
		type_category IS NULL
		THEN type_category::capital_project_category
	 WHEN type_category = 'ITT, Vehicles, and Equipment'
		THEN 'ITT, Vehicles and Equipment'::capital_project_category
  END AS category
FROM capital_project_source;

-- Move data from project source to project fund

-- I know what you're thinking; this is a lot of repeated code.
-- It's tempting to transform the table and use a regex on the column name to try generalizing the logic.
-- However, this goes against the grain for Postgres and introducing python is yet another tool to manage.
-- Once you get beyond the gut check, this code is fine. In fact, it's simple and expressive.
-- Also, as much as there is repeated code, there is non-repeated code that needs to be specified somewhere.
-- Don't spend too much time worrying about it or trying to "fix" it.

-- adopt
INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-non-exempt'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_ccnonexempt AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_ccexempt AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_citycost AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_nccstate AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_nccfederal AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_nccother AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-cost'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_noncitycost AS value
FROM capital_project_source;

-- allocate
INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-non-exempt'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_ccnonexempt AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_ccexempt AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_citycost AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_nccstate AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_nccfederal AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_nccother AS value
FROM capital_project_source;

-- commit
INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-non-exempt'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_ccnonexempt AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_ccexempt AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_citycost AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_nccstate AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_nccfederal AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_nccother AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-cost'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_noncitycost AS value
FROM capital_project_source;

-- spent
INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-non-exempt'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_ccnonexempt AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_ccexempt AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_citycost AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_nccstate AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_nccfederal AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_nccother AS value
FROM capital_project_source;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-cost'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_noncitycost AS value
FROM capital_project_source;

-- Move data from commitment source to commitment_type
INSERT INTO capital_commitment_type
SELECT DISTINCT
	commitment_code AS code,
	commitment_description AS description
FROM capital_commitment_source;

-- Move data from commitment source to agency_budget
INSERT INTO agency_budget
SELECT DISTINCT 
	SPLIT_PART(budget_line, '-', 1) AS code,
	project_type AS type,
	s_agency_acro AS sponsor
FROM capital_commitment_source;

-- Move data from commitment source to budget_line
INSERT INTO budget_line
SELECT DISTINCT 
	SPLIT_PART(budget_line, '-', 1) AS code,
	SPLIT_PART(budget_line, '-', 2) AS id
FROM capital_commitment_source;

-- Provide uuids to commitent source
SELECT gen_random_uuid() as id, *
INTO capital_commitment_source_id
FROM capital_commitment_source;

-- Move data from commitment source id to commitment
INSERT INTO captial_commitment
SELECT 
	id,
	commitment_code AS type,
	TO_DATE(plan_comm_date, 'MM/YY') AS planned_date,
	m_agency AS managing_code,
	project_id AS capital_project_id,
	SPLIT_PART(budget_line, '-', 1) AS budget_line_code,	
	SPLIT_PART(budget_line, '-', 2) AS budget_line_id
FROM capital_commitment_source_id;

-- Move data from commitment source id to commitment_fund
INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'city-non-exempt'::capital_fund_category AS category,
	plannedcommit_ccnonexempt AS value
FROM capital_commitment_source_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'city-exempt'::capital_fund_category AS category,
	plannedcommit_ccexempt AS value
FROM capital_commitment_source_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'non-city-state'::capital_fund_category AS category,
	plannedcommit_nccstate AS value
FROM capital_commitment_source_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'non-city-federal'::capital_fund_category AS category,
	plannedcommit_nccfederal AS value
FROM capital_commitment_source_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'non-city-other'::capital_fund_category AS category,
	plannedcommit_nccother AS value
FROM capital_commitment_source_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'non-city-cost'::capital_fund_category AS category,
	plannedcommit_noncitycost AS value
FROM capital_commitment_source_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'total'::capital_fund_category AS category,
	plannedcommit_total AS value
FROM capital_commitment_source_id;

-- End "commitment_transform"

