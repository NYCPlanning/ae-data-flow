DROP TABLE IF EXISTS
    source_agency
    CASCADE;

CREATE TABLE IF NOT EXISTS source_agency (
    agency_code char(3),
    source text,
    managing_agency_acronym text,
    managing_agency text
);