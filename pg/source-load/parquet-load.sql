INSTALL spatial;
LOAD spatial;
SELECT * FROM read_parquet('data/download/dcp_school_districts.parquet');
ATTACH 'dbname=data-flow user=postgres host=localhost password=postgres port=8001' AS postgres_db (TYPE postgres);
INSERT INTO postgres_db.source_school_district SELECT * FROM read_parquet('data/download/dcp_school_districts.parquet');