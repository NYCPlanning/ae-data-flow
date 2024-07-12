TRUNCATE 
	borough,
	city_council_district,
	community_district,
	land_use,
	tax_lot,
	zoning_district,
  	zoning_district_class,
	zoning_district_zoning_district_class,
	managing_code,
	agency,
	capital_project,
	capital_project_fund,
	capital_commitment_type,
	agency_budget,
	budget_line,
	capital_commitment,
	capital_commitment_fund
	CASCADE;

DROP TABLE IF EXISTS source_capital_commitment_id CASCADE;

INSERT INTO borough
	SELECT
		id,
		title,
		abbr
	FROM source_borough;

INSERT INTO city_council_district
SELECT
  coundist AS id,
  ST_Transform(wkt, 2263) AS li_ft,
  ST_Transform(wkt, 3857) AS mercator_fill,
  ST_Transform((ST_MaximumInscribedCircle(wkt)).center, 3857) AS mercator_label
FROM source_city_council_district;

INSERT INTO community_district
SELECT
  SUBSTRING(borocd::text, 1, 1) AS borough_id,
  SUBSTRING(borocd::text, 2, 3) AS id,
  ST_Transform(wkt, 3857) AS mercator_fill,
  ST_Transform((ST_MaximumInscribedCircle(wkt)).center, 3857) AS mercator_label,
  ST_Transform(wkt, 2263) AS li_ft
FROM source_community_district;

INSERT INTO land_use
    SELECT
        id,
        description,
        color
    FROM source_land_use;

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
FROM source_zoning_district
WHERE
    zonedist NOT IN ('PARK', 'BALL FIELD', 'PUBLIC PLACE', 'PLAYGROUND', 'BPC', '')
    AND ST_GEOMETRYTYPE(wkt) = 'ST_MultiPolygon';

INSERT INTO zoning_district_class
SELECT
	id,
	category::category,
	description,
	url,
	color
FROM source_zoning_district_class;

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

INSERT INTO managing_code
SELECT DISTINCT
	m_agency as id
FROM source_capital_project;

-- Move managing agencies from project table into agency table
INSERT INTO agency
SELECT DISTINCT
	m_agency_acro as initials,
	m_agency_name as name
FROM source_capital_project;

-- Move sponsoring agencies from commitment table into agency table
INSERT INTO agency
SELECT DISTINCT 
	s_agency_acro as initials,
	s_agency_name as name
FROM source_capital_commitment
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
  -- This was unintentional but the simplest way to rectify
  -- the data source with the API database is to coerce the
  -- source value to drop the oxford comma
  CASE 
	 WHEN type_category = 'Fixed Asset' OR
	 	type_category = 'Fixed Asset' OR
		type_category IS NULL
		THEN type_category::capital_project_category
	 WHEN type_category = 'ITT, Vehicles, and Equipment'
		THEN 'ITT, Vehicles and Equipment'::capital_project_category
  END AS category
FROM  source_capital_project;

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
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_ccexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_citycost AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_nccstate AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_nccfederal AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_nccother AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-cost'::capital_fund_category AS category,
	'adopt'::capital_project_fund_stage AS stage,
	adopt_noncitycost AS value
FROM source_capital_project;

-- allocate
INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-non-exempt'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_ccnonexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_ccexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_citycost AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_nccstate AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_nccfederal AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other'::capital_fund_category AS category,
	'allocate'::capital_project_fund_stage AS stage,
	allocate_nccother AS value
FROM source_capital_project;

-- commit
INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-non-exempt'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_ccnonexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_ccexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_citycost AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_nccstate AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_nccfederal AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_nccother AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-cost'::capital_fund_category AS category,
	'commit'::capital_project_fund_stage AS stage,
	commit_noncitycost AS value
FROM source_capital_project;

-- spent
INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-non-exempt'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_ccnonexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_ccexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_citycost AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_nccstate AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_nccfederal AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_nccother AS value
FROM source_capital_project;

INSERT INTO capital_project_fund
SELECT 
	gen_random_uuid() AS id,
	m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-cost'::capital_fund_category AS category,
	'spent'::capital_project_fund_stage AS stage,
	spent_noncitycost AS value
FROM source_capital_project;

-- Move data from commitment source to commitment_type
INSERT INTO capital_commitment_type
SELECT DISTINCT
	commitment_code AS code,
	commitment_description AS description
FROM source_capital_commitment;

-- Move data from commitment source to agency_budget
INSERT INTO agency_budget
SELECT DISTINCT 
	SPLIT_PART(budget_line, '-', 1) AS code,
	project_type AS type,
	s_agency_acro AS sponsor
FROM source_capital_commitment;

-- Move data from commitment source to budget_line
INSERT INTO budget_line
SELECT DISTINCT 
	SPLIT_PART(budget_line, '-', 1) AS code,
	SPLIT_PART(budget_line, '-', 2) AS id
FROM source_capital_commitment;

-- Provide uuids to commitment source
SELECT gen_random_uuid() as id, *
INTO source_capital_commitment_id
FROM source_capital_commitment;

-- Move data from commitment source id to commitment
INSERT INTO capital_commitment
SELECT 
	id,
	commitment_code AS type,
	TO_DATE(plan_comm_date, 'MM/YY') AS planned_date,
	m_agency AS managing_code,
	project_id AS capital_project_id,
	SPLIT_PART(budget_line, '-', 1) AS budget_line_code,	
	SPLIT_PART(budget_line, '-', 2) AS budget_line_id
FROM source_capital_commitment_id;

-- Move data from commitment source id to commitment_fund
INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'city-non-exempt'::capital_fund_category AS category,
	plannedcommit_ccnonexempt AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'city-exempt'::capital_fund_category AS category,
	plannedcommit_ccexempt AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'non-city-state'::capital_fund_category AS category,
	plannedcommit_nccstate AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'non-city-federal'::capital_fund_category AS category,
	plannedcommit_nccfederal AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'non-city-other'::capital_fund_category AS category,
	plannedcommit_nccother AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'non-city-cost'::capital_fund_category AS category,
	plannedcommit_noncitycost AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund
SELECT 
	gen_random_uuid() AS id, 
	id AS capital_commitment_id,
	'total'::capital_fund_category AS category,
	plannedcommit_total AS value
FROM source_capital_commitment_id;

WITH capital_project_spatial AS (
	SELECT 
		COALESCE(source_capital_project_m_poly.magency, source_capital_project_m_pnt.magency) AS managing_code,
		COALESCE(source_capital_project_m_poly.projectid, source_capital_project_m_pnt.projectid) id,
		source_capital_project_m_poly.wkt AS m_poly,
		source_capital_project_m_pnt.wkt AS m_pnt
	FROM source_capital_project_m_poly
	FULL OUTER JOIN source_capital_project_m_pnt
		ON source_capital_project_m_poly.magency = source_capital_project_m_pnt.magency AND 
			source_capital_project_m_poly.projectid = source_capital_project_m_pnt.projectid
		)
	UPDATE capital_project
-- 		Need to transform to 2263 because it is imported as 4326
		SET li_ft_m_pnt = ST_Transform(capital_project_spatial.m_pnt, 2263),
			li_ft_m_poly = ST_Transform(capital_project_spatial.m_poly, 2263),
			mercator_label = CASE 
								WHEN capital_project_spatial.m_pnt IS NOT NULL THEN ST_Transform(ST_PointOnSurface(capital_project_spatial.m_pnt), 3857)
								WHEN capital_project_spatial.m_poly IS NOT NULL THEN ST_Transform((ST_MaximumInscribedCircle(capital_project_spatial.m_poly)).center, 3857)
							END,
			mercator_fill_m_pnt = ST_Transform(capital_project_spatial.m_pnt, 3857),
			mercator_fill_m_poly = ST_Transform(capital_project_spatial.m_poly, 3857)
	FROM capital_project_spatial
	WHERE capital_project_spatial.managing_code = capital_project.managing_code AND
		capital_project_spatial.id = capital_project.id;