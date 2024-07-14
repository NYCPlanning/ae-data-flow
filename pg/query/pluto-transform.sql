
DROP TABLE IF EXISTS
	flow_borough,
	flow_land_use,
	flow_tax_lot
	CASCADE;

CREATE TABLE IF NOT EXISTS flow_borough 
	(LIKE borough INCLUDING ALL);

CREATE TABLE IF NOT EXISTS flow_land_use 
	(LIKE land_use INCLUDING ALL);

CREATE TABLE IF NOT EXISTS flow_tax_lot
	(LIKE tax_lot INCLUDING ALL);
	
INSERT INTO flow_borough
	SELECT
		id,
		title,
		abbr
	FROM source_borough;
	
INSERT INTO flow_land_use
    SELECT
        id,
        description,
        color
    FROM source_land_use;
	
INSERT INTO flow_tax_lot
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
INNER JOIN flow_borough AS borough ON source_pluto.borough=borough.abbr;

COMMIT;

COPY flow_borough TO '/var/lib/postgresql/data/borough.csv';
COPY flow_land_use TO '/var/lib/postgresql/data/land_use.csv';
COPY flow_tax_lot TO '/var/lib/postgresql/data/tax_lot.csv';
