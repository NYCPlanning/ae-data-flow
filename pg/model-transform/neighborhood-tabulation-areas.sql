TRUNCATE
  neighborhood_tabulation_area
  CASCADE;

INSERT INTO neighborhood_tabulation_area (
    name,
    year,
    code,
    li_ft,
    mercator_fill
)
SELECT
    nta_name AS name,
    2010 AS year,
    nta_code as code,
    ST_Transform(wkt, 2263) AS li_ft,
    ST_Transform(wkt, 3857) AS mercator_fill
FROM source_neighborhood_tabulation_area_2010

UNION ALL

SELECT
    nta_name AS name,
    2020 AS year,
    nta_2020 as code,
    ST_Transform(wkt, 2263) AS li_ft,
    ST_Transform(wkt, 3857) AS mercator_fill
FROM source_neighborhood_tabulation_area_2020;

COPY neighborhood_tabulation_area
    TO '/var/lib/postgresql/data/neighborhood_tabulation_area.csv';