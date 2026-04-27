TRUNCATE
  neighborhood_tabulation_area
  CASCADE;

INSERT INTO neighborhood_tabulation_area (
    vintage,
    nta_code,
    label
)
SELECT
    2010 AS vintage,
    nta_code,
    nta_name AS label
FROM source_neighborhood_tabulation_area_2010

UNION ALL

SELECT
    2020 AS vintage,
    nta_2020 AS nta_code,
    nta_name AS label
FROM source_neighborhood_tabulation_area_2020;

COPY neighborhood_tabulation_area
    TO '/var/lib/postgresql/data/neighborhood_tabulation_area.csv';