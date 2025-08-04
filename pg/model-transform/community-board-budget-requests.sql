TRUNCATE
	cbbr_policy_area,
	cbbr_need_group,
	cbbr_need,
	cbbr_agency_need,
	cbbr_agency_need_request,
	cbbr_agency_need_group
RESTART IDENTITY
CASCADE;

INSERT INTO cbbr_policy_area (description)
SELECT DISTINCT
		"Policy Area" AS description
FROM source_cbbr_option
ORDER BY
		source_cbbr_option."Policy Area";

INSERT INTO cbbr_need_group (description, policy_area_id)
WITH policy_area_need_group AS (
	SELECT DISTINCT
		"Policy Area" AS policy_area,
		"Need Group" AS need_group
	FROM source_cbbr_option
)
SELECT
	policy_area_need_group.need_group AS description,
	cbbr_policy_area.id AS policy_area_id
FROM policy_area_need_group
LEFT JOIN cbbr_policy_area ON
    cbbr_policy_area.description = policy_area_need_group.policy_area
ORDER BY policy_area_id,
    description;

ALTER TABLE source_cbbr_option
	ADD COLUMN IF NOT EXISTS
		agency_initials text;

UPDATE source_cbbr_option
	SET agency_initials =
		CASE
	    	WHEN "Agency" = 'Other' THEN 'OTH'
	    	WHEN "Agency" = 'Queens Library (QL)' THEN 'QPL'
	    	WHEN "Agency" = 'School Construction Authority' THEN 'SCA'
	    	WHEN "Agency" = 'Department of Information Technology and Telecommunications (DOITT)' THEN 'OTI'
			WHEN "Agency" = 'NYC Emergency Management (NYCEM)' THEN 'OEM'
	    	ELSE REPLACE(
	    			REPLACE(
	    				SUBSTRING("Agency", '\([A-Z]{1,}\)'),
	    			'(', ''),
	    		')', '')
	    END;

INSERT INTO cbbr_agency_need_group (agency_initials, need_group_id)
SELECT DISTINCT
	agency_initials,
   	cbbr_need_group.id AS need_group_id
FROM source_cbbr_option
LEFT JOIN cbbr_need_group ON
    source_cbbr_option."Need Group" = cbbr_need_group.description;

INSERT INTO cbbr_need (description)
SELECT DISTINCT
    "Need" AS need
FROM source_cbbr_option
    ORDER BY need;

INSERT INTO cbbr_agency_need (need_id, agency_initials)
WITH agency_need_option AS (
SELECT DISTINCT
    "Need" AS description,
    agency_initials
FROM source_cbbr_option
) SELECT
    cbbr_need.id,
    agency_need_option.agency_initials
FROM agency_need_option
LEFT JOIN cbbr_need ON
    agency_need_option.description = cbbr_need.description
    ORDER BY
        cbbr_need.id,
        agency_need_option.agency_initials;

INSERT INTO cbbr_request (description, type)
SELECT
    "Request" AS description,
    "Type" as type
FROM source_cbbr_option
    ORDER BY description, type;

WITH agency_need_request_type_option AS (
    SELECT DISTINCT
    	"Need" AS need,
        agency_initials,
    	"Request" AS request,
    	"Type" AS type
    FROM source_cbbr_option
), agency_initials_need_description AS (
    SELECT
    cbbr_agency_need.id AS agency_need_id,
    cbbr_need.description AS need_description,
    cbbr_agency_need.agency_initials
    FROM cbbr_agency_need
    LEFT JOIN cbbr_need ON
    	cbbr_need.id = cbbr_agency_need.need_id
) SELECT
   	agency_initials_need_description.agency_need_id AS agency_need_id,
    cbbr_request.id AS request_id
FROM agency_need_request_type_option
LEFT JOIN agency_initials_need_description ON
    agency_need_request_type_option.agency_initials = agency_initials_need_description.agency_initials
    	AND agency_need_request_type_option.need = agency_initials_need_description.need_description
LEFT JOIN cbbr_request ON
    agency_need_request_type_option.request = cbbr_request.description
    	AND agency_need_request_type_option.type = cbbr_request.type;

COPY cbbr_policy_area TO '/var/lib/postgresql/data/cbbr_policy_area.csv';
COPY cbbr_need_group TO '/var/lib/postgresql/data/cbbr_need_group.csv';
COPY cbbr_agency_need_group TO '/var/lib/postgresql/data/cbbr_agency_need_group.csv';
COPY cbbr_need TO '/var/lib/postgresql/data/cbbr_need.csv';
COPY cbbr_agency_need TO '/var/lib/postgresql/data/cbbr_agency_need.csv';
COPY cbbr_request TO '/var/lib/postgresql/data/cbbr_request.csv';
COPY cbbr_agency_need_request TO '/var/lib/postgresql/data/cbbr_agency_need_request.csv';
