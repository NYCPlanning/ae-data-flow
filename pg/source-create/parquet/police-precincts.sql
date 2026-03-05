INSTALL spatial;
LOAD spatial;

ATTACH ${URI} AS postgres_db (TYPE postgres);
DROP TABLE IF EXISTS postgres_db.source_police_precinct;
CREATE TABLE postgres_db.source_police_precinct (precicnt text, shape_leng float, shape_area float, geometry GEOMETRY);
INSERT INTO postgres_db.source_police_precinct SELECT * FROM read_parquet('dcp_policeprecincts.parquet');
SELECT * FROM 'dcp_policeprecincts.parquet';
CREATE TABLE IF NOT EXISTS source_police_precincts AS
    SELECT * FROM '/data/download/dcp_policeprecincts.parquet'; 

