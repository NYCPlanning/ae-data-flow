BEGIN;
	COPY borough ("id", "title", "abbr")
		FROM '../borough.csv'
		DELIMITER ','
		CSV HEADER;
	
COMMIT;

BEGIN;
	COPY land_use ("id", "description", "color")
		FROM '../land_use.csv'
		DELIMITER ','
		CSV HEADER;

COMMIT;

BEGIN;
	COPY pluto (
		"wkt",
		"borough_id",
		"block",
		"lot",
		"address",
		"land_use_id",
		"bbl"
	)
		FROM '../pluto.csv'
		DELIMITER ','
		CSV HEADER;

COMMIT;

INSERT INTO tax_lot
SELECT
	SUBSTRING(bbl, 1, 10) as bbl,
	borough.id as borough_id,
	block,
	lot,
	address,
	land_use_id,
	ST_GeomFromText(wkt, 4326) as wgs84,
	ST_GeomFromText(wkt, 2263) as li_ft
FROM pluto
INNER JOIN borough ON pluto.borough_id=borough.abbr;

BEGIN;
	COPY zoning_district (
		"id",
		"label",
		"wgs84",
		"li_ft"
	)
		FROM '../zoning_district.csv'
		DELIMITER ','
		CSV HEADER;

COMMIT;

BEGIN;
	COPY zoning_district_class (
		"id",
		"category",
		"description",
		"url",
		"color"
	)
		FROM '../zoning_district_class.csv'
		DELIMITER ','
		CSV HEADER;

COMMIT;

BEGIN;
	COPY zoning_district_zoning_district_class (
		"zoning_district_id",
		"zoning_district_class_id"
	)
		FROM '../zoning_district_zoning_district_class.csv'
		DELIMITER ','
		CSV HEADER;

COMMIT;
