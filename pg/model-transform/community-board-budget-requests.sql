TRUNCATE
	policy_area,
	needs_group,
	need,
	need_agency,
	need_agency_request,
	agency_needs_group
RESTART IDENTITY
CASCADE;

INSERT INTO policy_area (description)
SELECT DISTINCT
		"Policy Area" AS description
FROM source_community_board_budget_request_options
ORDER BY
		source_community_board_budget_request_options."Policy Area";

INSERT INTO needs_group (description, policy_area_id)
WITH policy_area_need_group AS (
	SELECT DISTINCT
		"Policy Area" AS policy_area,
		"Need Group" AS need_group
	FROM source_community_board_budget_request_options
)
SELECT
	policy_area_need_group.need_group AS description,
	policy_area.id AS policy_area_id
FROM policy_area_need_group
LEFT JOIN policy_area ON
    policy_area.description = policy_area_need_group.policy_area
ORDER BY policy_area_id,
    description;

ALTER TABLE source_community_board_budget_request_options
	ADD COLUMN IF NOT EXISTS
		agency_initials text;

UPDATE source_community_board_budget_request_options
	SET agency_initials =
		CASE
	    	WHEN "Agency" = 'Other' THEN 'OTH'
	    	WHEN "Agency" = 'Queens Library (QL)' THEN 'QPL'
	    	WHEN "Agency" = 'School Construction Authority' THEN 'SCA'
	    	WHEN "Agency" = 'Department of Information Technology and Telecommunications (DOITT)' THEN 'OTI'
	    	ELSE REPLACE(
	    			REPLACE(
	    				SUBSTRING("Agency", '\([A-Z]{1,}\)'),
	    			'(', ''),
	    		')', '')
	    END;

-- Temporary code to insert agencies from cbbr into table
INSERT INTO agency (initials, name)
SELECT DISTINCT
	agency_initials,
	"Agency"
FROM source_community_board_budget_request_options
ON CONFLICT DO NOTHING;
-- End temporary code

INSERT INTO agency_needs_group (agency_initials, needs_group_id)
SELECT DISTINCT
	agency_initials,
   	needs_group.id AS needs_group_id
FROM source_community_board_budget_request_options
LEFT JOIN needs_group ON
    source_community_board_budget_request_options."Need Group" = needs_group.description;

INSERT INTO need (description)
SELECT DISTINCT
    "Need" AS need
FROM source_community_board_budget_request_options
    ORDER BY need;

INSERT INTO need_agency (need_id, agency_initials)
WITH need_agency_options AS (
SELECT DISTINCT
    "Need" AS description,
    agency_initials
FROM source_community_board_budget_request_options
) SELECT
    need.id,
    need_agency_options.agency_initials
FROM need_agency_options
LEFT JOIN need ON
    need_agency_options.description = need.description
    ORDER BY
        need.id,
        need_agency_options.agency_initials;

INSERT INTO request (description, type)
SELECT
    "Request" AS description,
    "Type" as type
FROM source_community_board_budget_request_options
    ORDER BY description, type;

WITH need_agency_request_type_options AS (
    SELECT DISTINCT
    	"Need" AS need,
        agency_initials,
    	"Request" AS request,
    	"Type" AS type
    FROM source_community_board_budget_request_options
), need_description_agency_initals AS (
    SELECT
    need_agency.id AS need_agency_id,
    need.description AS need_description,
    need_agency.agency_initials
    FROM need_agency
    LEFT JOIN need ON
    	need.id = need_agency.need_id
) SELECT
   	need_description_agency_initals.need_agency_id AS need_agency_id,
    request.id AS request_id
FROM need_agency_request_type_options
LEFT JOIN need_description_agency_initals ON
    need_agency_request_type_options.agency_initials = need_description_agency_initals.agency_initials
    	AND need_agency_request_type_options.need = need_description_agency_initals.need_description
LEFT JOIN request ON
    need_agency_request_type_options.request = request.description
    	AND need_agency_request_type_options.type = request.type;
