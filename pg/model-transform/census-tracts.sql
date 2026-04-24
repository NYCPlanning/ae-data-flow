TRUNCATE
  census_tracts_2010,
  census_tracts_2020
  CASCADE;

INSERT INTO census_tracts_2010
  SELECT
    census_tract_label,
    borough_code,
    borough_name,
    census_tract_2010,
    borough_code_census_tract_2010,
    community_development_eligible,
    nta_code,
    nta_name,
    puma,
    shape_leng,
    shape_area,
    ST_Transform(wkt, 2263) as li_ft
  FROM source_census_tracts_2010;

  INSERT INTO census_tracts_2020
  SELECT
    census_tract_label,
    borough_code,
    borough_name,
    census_tract_2020,
    borough_code_census_tract_2020,
    community_development_eligible,
    nta_name,
    nta_2020,
    cdta_2020,
    cdta_name,
    geo_id,
    puma,
    shape_leng,
    shape_area,
    ST_Transform(wkt, 2263) as li_ft
  FROM source_census_tracts_2020;