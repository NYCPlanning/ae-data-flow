TRUNCATE
    community_board_budget_request
    CASCADE;

INSERT INTO community_board_budget_request_agency_response
SELECT DISTINCT ON (agency_response)
	DENSE_RANK() OVER (ORDER BY agency_response) AS id,
	agency_response
FROM
	source_community_board_budget_request;

INSERT INTO community_board_budget_request
SELECT
	source_community_board_budget_request.tracking_code,
	source_community_board_budget_request.borough_code AS borough_id,
	SUBSTRING(source_community_board_budget_request.commdist, 2, 3) AS community_district_id,
	CASE
		WHEN type_br = 'C' THEN 'CAPITAL'
		WHEN type_br = 'E' THEN 'EXPENSE'
	END AS type,
	source_community_board_budget_request.priority,
	community_board_budget_request_agency_response.id AS agency_response_id,
	source_community_board_budget_request.explanation,
	ARRAY[supporters_1, supporters_2]
FROM source_community_board_budget_request
LEFT JOIN community_board_budget_request_agency_response
	ON (community_board_budget_request_agency_response.value = source_community_board_budget_request.agency_response);
