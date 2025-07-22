TRUNCATE
	policy_area,
	needs_group
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
    policy_area.description = policy_area_need_group.policy_area;
    -- TODO: orderby policy area id and needs group description


-- TODO: modify to populate existing agency table
INSERT INTO agency
WITH agency_options AS (
SELECT
	DISTINCT
		"Need Group" AS needs_group,
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
		END AS initials,
		"Agency" AS name
FROM source_community_board_budget_request_options
) SELECT
    agency_options.initials,
    agency_options.name,
    needs_group.id AS community_board_budget_request_needs_group_id
FROM agency_options
LEFT JOIN needs_group ON
    agency_options.needs_group = needs_group.description;
