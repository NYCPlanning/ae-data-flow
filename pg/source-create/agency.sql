DROP TABLE IF EXISTS
    source_de_agency,
    source_comp_agency
    CASCADE;

CREATE TABLE IF NOT EXISTS source_de_agency (
    facdb_level text,
    facdb_agencyname_revised text,
    facdb_agencyname text,
    facdb_agencyabbrev text,
    cape_agencycode text,
    cape_agencyacronym text,
    cape_agency text
);

CREATE TABLE IF NOT EXISTS source_comp_agency (
    "Agency Code" text,
    "Agency Name" text,
    "Agency Short Name" text
);
