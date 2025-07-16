DROP TABLE IF EXISTS
    source_agency
    CASCADE;

CREATE TABLE IF NOT EXISTS source_agency (
    agency_code char(3),
    source text,
    agency_name text,
    proposed_agency_name text,
    proposed_initials text,
    ad_edit text
);