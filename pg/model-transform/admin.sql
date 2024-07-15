DROP TABLE IF EXISTS
	flow_city_council_district,
	flow_community_district,
	city_council_district,
	community_district
    CASCADE;

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

COPY city_council_district TO '/var/lib/postgresql/data/city_council_district.csv';
COPY community_district TO '/var/lib/postgresql/data/community_district.csv';
