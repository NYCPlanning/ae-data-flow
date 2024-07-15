TRUNCATE
	land_use,
	tax_lot
	CASCADE;

INSERT INTO land_use
    SELECT
        id,
        description,
        color
    FROM source_land_use;

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

COPY land_use TO '/var/lib/postgresql/data/land_use.csv';
COPY tax_lot TO '/var/lib/postgresql/data/tax_lot.csv';
