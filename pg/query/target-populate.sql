TRUNCATE 
	borough,
	city_council_district,
	land_use,
	tax_lot,
	zoning_district
	CASCADE;

INSERT INTO borough
	SELECT
		id,
		title,
		abbr
	FROM source_borough;

INSERT INTO land_use
    SELECT
        id,
        description,
        color
    FROM source_land_use;

INSERT INTO city_council_district
SELECT
  coundist AS id,
  ST_Transform(wkt, 2263) AS li_ft,
  ST_Transform(wkt, 3857) AS mercator_fill,
  ST_Transform((ST_MaximumInscribedCircle(wkt)).center, 3857) AS mercator_label
FROM source_city_council_district;

-- INSERT INTO tax_lot
-- SELECT
-- 	SUBSTRING(bbl, 1, 10) as bbl,
-- 	borough.id as borough_id,
-- 	block,
-- 	lot,
-- 	address,
-- 	land_use as land_use_id,
-- 	ST_Transform(wkt, 4326) as wgs84,
-- 	wkt as li_ft
-- FROM source_pluto
-- INNER JOIN borough ON source_pluto.borough=borough.abbr;

INSERT INTO zoning_district
SELECT
    GEN_RANDOM_UUID() AS id,
    zonedist AS label,
    wkt as wgs84,
		ST_Transform(wkt, 2263) as li_ft
FROM source_zoning_district
WHERE
    zonedist NOT IN ('PARK', 'BALL FIELD', 'PUBLIC PLACE', 'PLAYGROUND', 'BPC', '')
    AND ST_GEOMETRYTYPE(wkt) = 'ST_MultiPolygon';
