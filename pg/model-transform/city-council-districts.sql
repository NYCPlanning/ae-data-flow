TRUNCATE
	city_council_district
    CASCADE;

INSERT INTO city_council_district
SELECT
  coundist AS id,
  ST_Transform(wkt, 2263) AS li_ft,
  ST_Transform(wkt, 3857) AS mercator_fill,
  ST_Transform((ST_MaximumInscribedCircle(wkt)).center, 3857) AS mercator_label
FROM source_city_council_district;

COPY city_council_district TO '/var/lib/postgresql/data/city_council_district.csv';