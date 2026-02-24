DROP TABLE IF EXISTS
    source_census_tracts_2010,
    source_census_tracts_2020,
    CASCADE;

CREATE TABLE IF NOT EXISTS source_census_tracts_2010 (
    census_tract_label text,
    borough_code char(1),
    borough_name text,
    census_tract_2010 text,
    borough_code_census_tract_2010 text,
    community_development_eligible char(1) CHECK (community_development_eligible IN ('I', 'E')),
    nta_code text,
    nta_name text,
    puma text,
    shape_leng float,
    shape_area float,
    wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);

CREATE TABLE IF NOT EXISTS source_census_tracts_2020 (
    census_tract_label text,
    borough_code char(1),
    borough_name text,
    census_tract_2020 text,
    borough_code_census_tract_2020 text,
    community_development_eligible  char(1) CHECK (community_development_eligible IN ('I', 'E')),
    nta_name text,
    nta_2020 text,
    cdta_2020 text,
    cdta_name text,
    geo_id text,
    puma text,
    shape_leng float,
    shape_area float,
    wkt geometry(MULTIPOLYGON, 4326) NOT NULL
);