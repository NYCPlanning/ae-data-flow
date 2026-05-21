DROP TABLE IF EXISTS
    source_agency
    CASCADE;

CREATE TABLE IF NOT EXISTS source_agency (
    managing_agency_acronym text,
    managing_agency text,
    source text,
    manages_capital_projects boolean,
    operates_facilities boolean,
    agency_code char(3),
    overlevel text,
    optype text
);