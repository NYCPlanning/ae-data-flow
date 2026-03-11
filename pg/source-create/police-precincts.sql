DROP TABLE IF EXISTS
    source_police_precincts,
    CASCADE;

CREATE TABLE IF NOT EXISTS source_police_precincts (
    police_precinct text,
    shape_area text,
    shape_leng text,
    wkt text
);

-- COPY source_police_precincts from 'pg/source-create/dcp_policeprecincts.parquet'; 
-- SELECT * FROM source_police_precincts;

-- parquet.schema('dcp_policeprecincts.parquet');