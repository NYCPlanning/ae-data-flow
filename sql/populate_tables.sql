\COPY borough ("id", "title", "abbr") FROM './seeds/borough.csv' DELIMITER ',' CSV HEADER;

\COPY land_use ("id", "description", "color") FROM './seeds/land_use.csv' DELIMITER ',' CSV HEADER;

\COPY zoning_district_class ( "id", "category", "description", "url", "color" ) FROM './seeds/zoning_district_class.csv' DELIMITER ',' CSV HEADER;

INSERT INTO tax_lot
SELECT
	SUBSTRING(bbl, 1, 10) as bbl,
	borough.id as borough_id,
	block,
	lot,
	address,
	land_use as land_use_id,
	ST_Transform(wkt, 4326) as wgs84,
	wkt as li_ft
FROM source_pluto
INNER JOIN borough ON source_pluto.borough=borough.abbr;

INSERT INTO zoning_district
SELECT
    GEN_RANDOM_UUID() AS id,
    zonedist AS label,
    wkt as wgs84,
		ST_Transform(wkt, 2263) as li_ft
FROM source_zoning_districts
WHERE
    zonedist NOT IN ('PARK', 'BALL FIELD', 'PUBLIC PLACE', 'PLAYGROUND', 'BPC', '')
    AND ST_GEOMETRYTYPE(wkt) = 'ST_MultiPolygon';

INSERT INTO zoning_district_zoning_district_class
WITH split_zones AS (
    SELECT
        id,
        UNNEST(STRING_TO_ARRAY(label, '/')) AS individual_zoning_district
    FROM zoning_district
)
SELECT
    id AS zoning_district_id,
    (REGEXP_MATCH(individual_zoning_district, '^(\w\d+)(?:[^\d].*)?$'))[1] AS zoning_district_class_id
FROM split_zones;
