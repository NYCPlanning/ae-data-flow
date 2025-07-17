TRUNCATE
    agency
    CASCADE;

INSERT INTO agency
SELECT DISTINCT
    proposed_agency_name as name,
    proposed_initials as initials
FROM source_agency;

COPY agency TO '/var/lib/postgresql/data/agency.csv';