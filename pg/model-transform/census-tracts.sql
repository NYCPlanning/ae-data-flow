TRUNCATE
  census_tract
  CASCADE;

INSERT INTO census_tract (
  vintage,
  census_tract,
  label
)
SELECT
  2010 AS vintage,
  census_tract_2010  AS census_tract,
  census_tract_label AS label
FROM source_census_tracts_2010

UNION ALL

SELECT
  2020 AS vintage,
  census_tract_2020 AS census_tract,
  census_tract_label AS label
FROM source_census_tracts_2020;

COPY census_tract TO '/var/lib/postgresql/data/census_tract.csv';
