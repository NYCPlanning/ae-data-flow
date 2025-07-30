TRUNCATE
	managing_code,
	capital_project,
	capital_project_fund,
	capital_commitment_type,
	capital_project_checkbook,
	agency_budget,
	budget_line,
	capital_commitment,
	capital_commitment_fund
	CASCADE;

DROP TABLE IF EXISTS source_capital_commitment_id CASCADE;

INSERT INTO managing_code
SELECT DISTINCT
	m_agency as id
FROM source_capital_project;

ALTER TABLE source_capital_project
    ADD COLUMN IF NOT EXISTS refined_m_agency char(3),
    ADD COLUMN IF NOT EXISTS refined_m_agency_acro text;

UPDATE source_capital_project
    SET
        refined_m_agency = CASE
            WHEN m_agency IN ('998', '801') THEN '801'
            ELSE m_agency
        END,
        refined_m_agency_acro = CASE
            WHEN m_agency_acro IN ('EDC', 'BNY', 'TGI') THEN 'SBS'
            WHEN m_agency_acro IN ('DOE/SCA') THEN 'DOE'
      		WHEN m_agency_acro IN ('QBPL') THEN 'QPL'
      		WHEN m_agency_acro IN ('DOITT') THEN 'OTI'
            ELSE m_agency_acro
        END;

-- Move project source into project target
INSERT INTO capital_project (
    managing_code,
    id,
    managing_agency,
    description,
    min_date,
    max_date,
    category
)
SELECT
	refined_m_agency AS managing_code,
	proj_id AS id,
	refined_m_agency_acro AS managing_agency,
	description,
	min_date,
	max_date,
	type_category AS category
FROM  source_capital_project
;

-- I know what you're thinking; this is a lot of repeated code.
-- It's tempting to transform the table and use a regex on the column name to try generalizing the logic.
-- However, this goes against the grain for Postgres and introducing python is yet another tool to manage.
-- Once you get beyond the gut check, this code is fine. In fact, it's simple and expressive.
-- Also, as much as there is repeated code, there is non-repeated code that needs to be specified somewhere.
-- Don't spend too much time worrying about it or trying to "fix" it.

-- adopt
INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-non-exempt' AS category,
	'adopt' AS stage,
	adopt_ccnonexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt' AS category,
	'adopt' AS stage,
	adopt_ccexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost' AS category,
	'adopt' AS stage,
	adopt_citycost AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state' AS category,
	'adopt' AS stage,
	adopt_nccstate AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal' AS category,
	'adopt' AS stage,
	adopt_nccfederal AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other' AS category,
	'adopt' AS stage,
	adopt_nccother AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-cost' AS category,
	'adopt' AS stage,
	adopt_noncitycost AS value
FROM source_capital_project;

-- allocate
INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-non-exempt' AS category,
	'allocate' AS stage,
	allocate_ccnonexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt' AS category,
	'allocate' AS stage,
	allocate_ccexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost' AS category,
	'allocate' AS stage,
	allocate_citycost AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state' AS category,
	'allocate' AS stage,
	allocate_nccstate AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal' AS category,
	'allocate' AS stage,
	allocate_nccfederal AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other' AS category,
	'allocate' AS stage,
	allocate_nccother AS value
FROM source_capital_project;

-- commit
INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-non-exempt' AS category,
	'commit' AS stage,
	commit_ccnonexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt' AS category,
	'commit' AS stage,
	commit_ccexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost' AS category,
	'commit' AS stage,
	commit_citycost AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state' AS category,
	'commit' AS stage,
	commit_nccstate AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal' AS category,
	'commit' AS stage,
	commit_nccfederal AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other' AS category,
	'commit' AS stage,
	commit_nccother AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-cost' AS category,
	'commit' AS stage,
	commit_noncitycost AS value
FROM source_capital_project;

-- spent
INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-non-exempt' AS category,
	'spent' AS stage,
	spent_ccnonexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-exempt' AS category,
	'spent' AS stage,
	spent_ccexempt AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'city-cost' AS category,
	'spent' AS stage,
	spent_citycost AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-state' AS category,
	'spent' AS stage,
	spent_nccstate AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-federal' AS category,
	'spent' AS stage,
	spent_nccfederal AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-other' AS category,
	'spent' AS stage,
	spent_nccother AS value
FROM source_capital_project;

INSERT INTO capital_project_fund (
    id,
    managing_code,
    capital_project_id,
    capital_fund_category,
    stage,
    value
)
SELECT
	gen_random_uuid() AS id,
	refined_m_agency AS managing_code,
	proj_id AS capital_project_id,
	'non-city-cost' AS category,
	'spent' AS stage,
	spent_noncitycost AS value
FROM source_capital_project;

-- Move data from commitment source to commitment_type
INSERT INTO capital_commitment_type (
    code,
    description
)
SELECT DISTINCT
	commitment_code AS code,
	commitment_description AS description
FROM source_capital_commitment;

ALTER TABLE source_capital_commitment
    ADD COLUMN IF NOT EXISTS refined_budget_code text,
    ADD COLUMN IF NOT EXISTS refined_budget_id text,
    ADD COLUMN IF NOT EXISTS refined_sponsor text,
    ADD COLUMN IF NOT EXISTS refined_plan_comm_date date,
    ADD COLUMN IF NOT EXISTS refined_m_agency char(3);

UPDATE source_capital_commitment
    SET
        refined_budget_code = SPLIT_PART(budget_line, '-', 1),
        refined_budget_id = SPLIT_PART(budget_line, '-', 2),
        refined_sponsor = CASE
            WHEN s_agency_acro IN ('QBPL') THEN 'QPL'
      		WHEN s_agency_acro IN ('HRA/DSS') THEN 'HRA'
      		WHEN s_agency_acro IN ('DOITT') THEN 'OTI'
            ELSE s_agency_acro
        END,
        refined_plan_comm_date = TO_DATE(plan_comm_date, 'MM/YY'),
        refined_m_agency = CASE
            WHEN m_agency IN ('998', '801') THEN '801'
            ELSE m_agency
        END;

-- Move data from commitment source to agency_budget
INSERT INTO agency_budget (
    code,
    type,
    sponsor
)
SELECT DISTINCT
	refined_budget_code AS code,
	project_type AS type,
	refined_sponsor AS sponsor
FROM source_capital_commitment;

-- Move data from commitment source to budget_line
INSERT INTO budget_line (
    code,
    id
)
SELECT DISTINCT
	refined_budget_code AS code,
	refined_budget_id AS id
FROM source_capital_commitment;

-- Provide uuids to commitment source
SELECT gen_random_uuid() as id, *
INTO source_capital_commitment_id
FROM source_capital_commitment;

-- Move data from commitment source id to commitment
INSERT INTO capital_commitment (
    id,
    type,
    planned_date,
    managing_code,
    capital_project_id,
    budget_line_code,
    budget_line_id
)
SELECT
	id,
	commitment_code AS type,
	refined_plan_comm_date AS planned_date,
	refined_m_agency AS managing_code,
	project_id AS capital_project_id,
	refined_budget_code AS budget_line_code,
	refined_budget_id AS budget_line_id
FROM source_capital_commitment_id;

-- Move data from commitment source id to commitment_fund
INSERT INTO capital_commitment_fund (
    id,
    capital_commitment_id,
    capital_fund_category,
    value
)
SELECT
	gen_random_uuid() AS id,
	id AS capital_commitment_id,
	'city-non-exempt' AS category,
	plannedcommit_ccnonexempt AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund (
    id,
    capital_commitment_id,
    capital_fund_category,
    value
)
SELECT
	gen_random_uuid() AS id,
	id AS capital_commitment_id,
	'city-exempt' AS category,
	plannedcommit_ccexempt AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund (
    id,
    capital_commitment_id,
    capital_fund_category,
    value
)
SELECT
	gen_random_uuid() AS id,
	id AS capital_commitment_id,
	'non-city-state' AS category,
	plannedcommit_nccstate AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund (
    id,
    capital_commitment_id,
    capital_fund_category,
    value
)
SELECT
	gen_random_uuid() AS id,
	id AS capital_commitment_id,
	'non-city-federal' AS category,
	plannedcommit_nccfederal AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund (
    id,
    capital_commitment_id,
    capital_fund_category,
    value
)
SELECT
	gen_random_uuid() AS id,
	id AS capital_commitment_id,
	'non-city-other' AS category,
	plannedcommit_nccother AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund (
    id,
    capital_commitment_id,
    capital_fund_category,
    value
)
SELECT
	gen_random_uuid() AS id,
	id AS capital_commitment_id,
	'non-city-cost' AS category,
	plannedcommit_noncitycost AS value
FROM source_capital_commitment_id;

INSERT INTO capital_commitment_fund (
    id,
    capital_commitment_id,
    capital_fund_category,
    value
)
SELECT
	gen_random_uuid() AS id,
	id AS capital_commitment_id,
	'total' AS category,
	plannedcommit_total AS value
FROM source_capital_commitment_id;

ALTER TABLE source_capital_project_m_poly
    ADD COLUMN IF NOT EXISTS refined_magency char(3);

UPDATE source_capital_project_m_poly
    SET
        refined_magency = CASE
            WHEN magency IN ('998', '801') THEN '801'
            ELSE magency
        END;

ALTER TABLE source_capital_project_m_pnt
    ADD COLUMN IF NOT EXISTS refined_magency char(3);

UPDATE source_capital_project_m_pnt
    SET
        refined_magency = CASE
            WHEN magency IN ('998', '801') THEN '801'
            ELSE magency
        END;

WITH capital_project_spatial AS (
	SELECT
		COALESCE(source_capital_project_m_poly.refined_magency, source_capital_project_m_pnt.refined_magency) AS managing_code,
		COALESCE(source_capital_project_m_poly.projectid, source_capital_project_m_pnt.projectid) AS id,
		source_capital_project_m_poly.wkt AS m_poly,
		source_capital_project_m_pnt.wkt AS m_pnt
	FROM source_capital_project_m_poly
	FULL OUTER JOIN source_capital_project_m_pnt
		ON source_capital_project_m_poly.refined_magency = source_capital_project_m_pnt.refined_magency AND
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


COPY managing_code TO '/var/lib/postgresql/data/managing_code.csv';
COPY capital_project TO '/var/lib/postgresql/data/capital_project.csv';
COPY capital_project_fund TO '/var/lib/postgresql/data/capital_project_fund.csv';
COPY capital_commitment_type TO '/var/lib/postgresql/data/capital_commitment_type.csv';
COPY capital_project_checkbook TO '/var/lib/postgresql/data/capital_project_checkbook.csv';
COPY agency_budget TO '/var/lib/postgresql/data/agency_budget.csv';
COPY budget_line TO '/var/lib/postgresql/data/budget_line.csv';
COPY capital_commitment TO '/var/lib/postgresql/data/capital_commitment.csv';
COPY capital_commitment_fund TO '/var/lib/postgresql/data/capital_commitment_fund.csv';
