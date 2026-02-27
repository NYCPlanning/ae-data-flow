DROP TABLE IF EXISTS
    source_police_precincts,
    CASCADE;

CREATE TABLE IF NOT EXISTS source_police_precincts AS
    SELECT * FROM '/data/download/dcp_policeprecincts.parquet'; 