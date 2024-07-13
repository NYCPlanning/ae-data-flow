BEGIN;
TRUNCATE 
	borough,
	city_council_district,
	community_district,
	land_use,
	tax_lot,
	zoning_district,
  	zoning_district_class,
	zoning_district_zoning_district_class,
	managing_code,
	agency,
	capital_project,
	capital_project_fund,
	capital_commitment_type,
	agency_budget,
	budget_line,
	capital_commitment,
	capital_commitment_fund,
	capital_project_checkbook
	CASCADE;

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

INSERT INTO borough
	SELECT * FROM flow_borough;
	
INSERT INTO land_use
	SELECT * FROM flow_land_use;
	
INSERT INTO tax_lot
	SELECT * FROM flow_tax_lot;

COMMIT;

BEGIN;
ALTER TABLE tax_lot
	ADD CONSTRAINT bbl_check CHECK (bbl SIMILAR TO '[0-9]{10}');
	
COMMIT;

BEGIN;

UPDATE tax_lot
	SET bbl = 100001001
	WHERE bbl = '1000010010';

ROLLBACK;
