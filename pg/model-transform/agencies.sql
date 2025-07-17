TRUNCATE
    agency
    CASCADE;

INSERT INTO agency
SELECT
    agency_code,
    source,
    agency_name,
    proposed_agency_name,
    proposed_initials,
    ad_edit
FROM source_agency;

COPY agency TO '/var/lib/postgresql/data/agency.csv';