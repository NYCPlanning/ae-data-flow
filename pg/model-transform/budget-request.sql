TRUNCATE
    policy_area,
    need_group,
    cbbr_agency,
    type,
    need,
    request
    -- budget_request
        CASCADE;
    -- ;


INSERT INTO policy_area
    SELECT DISTINCT policy_area as policy_area
FROM source_cbbr_options
WHERE policy_area IS NOT NULL;


INSERT INTO need_group
SELECT DISTINCT need_group as need_group
FROM source_cbbr_options
WHERE need_group IS NOT NULL;

INSERT INTO cbbr_agency
SELECT DISTINCT
    agency as agency
FROM source_cbbr_options
WHERE agency IS NOT NULL
;

INSERT INTO type 
SELECT DISTINCT
    type as type
FROM source_cbbr_options
WHERE type IS NOT NULL
;

INSERT INTO need 
SELECT DISTINCT
    need as need
FROM source_cbbr_options
WHERE need IS NOT NULL
;

INSERT INTO request 
SELECT DISTINCT
    request as request
FROM source_cbbr_options
WHERE request IS NOT NULL
;