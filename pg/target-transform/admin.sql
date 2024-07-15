DROP TABLE IF EXISTS
	flow_city_council_district,
	flow_community_district
    CASCADE;

CREATE TABLE IF NOT EXISTS flow_city_council_district
	(LIKE city_council_district INCLUDING ALL);

CREATE TABLE IF NOT EXISTS flow_community_district 
	(LIKE community_district INCLUDING ALL);

INSERT INTO city_council_district
SELECT
  coundist AS id,
  ST_Transform(wkt, 2263) AS li_ft,
  ST_Transform(wkt, 3857) AS mercator_fill,
  ST_Transform((ST_MaximumInscribedCircle(wkt)).center, 3857) AS mercator_label
FROM source_city_council_district;

INSERT INTO community_district
SELECT
  SUBSTRING(borocd::text, 1, 1) AS borough_id,
  SUBSTRING(borocd::text, 2, 3) AS id,
  ST_Transform(wkt, 3857) AS mercator_fill,
  ST_Transform((ST_MaximumInscribedCircle(wkt)).center, 3857) AS mercator_label,
  ST_Transform(wkt, 2263) AS li_ft
FROM source_community_district;
