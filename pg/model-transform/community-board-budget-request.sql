TRUNCATE
    community_board_budget_request
    CASCADE;

INSERT INTO community_board_budget_request
SELECT
	tracking_code,
	borough_code AS borough_id,
	SUBSTRING(commdist, 2, 3) AS community_district_id,
	CASE
		WHEN type_br = 'C' THEN 'CAPITAL'
		WHEN type_br = 'E' THEN 'EXPENSE'
	END AS type
FROM source_community_board_budget_request;
