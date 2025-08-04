TRUNCATE
	cbbr_policy_area,
	cbbr_need_group,
	cbbr_need,
	cbbr_request,
	cbbr_option_cascade
RESTART IDENTITY
CASCADE;

INSERT INTO cbbr_policy_area (description)
SELECT DISTINCT
	"Policy Area" AS description
FROM source_cbbr_option
ORDER BY description;

INSERT INTO cbbr_need_group (description)
SELECT DISTINCT
	"Need Group" AS description
FROM source_cbbr_option
ORDER BY description;

INSERT INTO cbbr_need (description)
SELECT DISTINCT
    "Need" AS description
FROM source_cbbr_option
    ORDER BY description;

INSERT INTO cbbr_request (description)
SELECT DISTINCT
    "Request" AS description
FROM source_cbbr_option
    ORDER BY description;

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

INSERT INTO cbbr_option_cascade (
	policy_area_id,
	need_group_id,
	agency_initials,
	type,
	need_id,
	request_id
)
SELECT
	DISTINCT
	cbbr_policy_area.id as policy_area_id,
	cbbr_need_group.id as need_group_id,
	source_cbbr_option.agency_initials as agency_initials,
	source_cbbr_option."Type" as type,
	cbbr_need.id as need_id,
	cbbr_request.id as request_id
FROM source_cbbr_option
LEFT JOIN cbbr_policy_area ON cbbr_policy_area.description = source_cbbr_option."Policy Area"
LEFT JOIN cbbr_need_group ON cbbr_need_group.description = source_cbbr_option."Need Group"
LEFT JOIN cbbr_need ON cbbr_need.description = source_cbbr_option."Need"
LEFT JOIN cbbr_request ON cbbr_request.description = source_cbbr_option."Request"
WHERE
	cbbr_policy_area.description = source_cbbr_option."Policy Area"
	AND cbbr_need_group.description = source_cbbr_option."Need Group"
	AND cbbr_need.description = source_cbbr_option."Need"
	AND cbbr_request.description = source_cbbr_option."Request";

COPY cbbr_policy_area TO '/var/lib/postgresql/data/cbbr_policy_area.csv';
COPY cbbr_need_group TO '/var/lib/postgresql/data/cbbr_need_group.csv';
COPY cbbr_need TO '/var/lib/postgresql/data/cbbr_need.csv';
COPY cbbr_request TO '/var/lib/postgresql/data/cbbr_request.csv';
COPY cbbr_option_cascade TO '/var/lib/postgresql/data/cbbr_option_cascade.csv';
