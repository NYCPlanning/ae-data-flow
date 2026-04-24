TRUNCATE
  census_tract
  CASCADE;

INSERT INTO census_tract (
  borough_id,
  label,
  year,
  li_ft,
  mercator_fill
)
SELECT
  borough_code AS borough_id,
  census_tract_label AS label,
  2010 AS year,
  ST_Transform(wkt, 2263) AS li_ft,
  ST_Transform(wkt, 3857) AS mercator_fill
FROM source_census_tracts_2010

UNION ALL

SELECT
  borough_code AS borough_id,
  census_tract_label AS label,
  2020 AS year,
  ST_Transform(wkt, 2263) AS li_ft,
  ST_Transform(wkt, 3857) AS mercator_fill
FROM source_census_tracts_2020;

COPY census_tract TO '/var/lib/postgresql/data/census_tract.csv';
