TRUNCATE
	community_district
    CASCADE;

INSERT INTO community_district
SELECT
  SUBSTRING(borocd::text, 1, 1) AS borough_id,
  SUBSTRING(borocd::text, 2, 3) AS id,
  ST_Transform(wkt, 3857) AS mercator_fill,
  ST_Transform((ST_MaximumInscribedCircle(wkt)).center, 3857) AS mercator_label,
  ST_Transform(wkt, 2263) AS li_ft
FROM source_community_district;

COPY community_district TO '/var/lib/postgresql/data/community_district.csv';