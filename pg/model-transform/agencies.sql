TRUNCATE
    agency
    CASCADE;

INSERT INTO agency
SELECT DISTINCT
    proposed_initials as initials,
    proposed_agency_name as name
FROM source_agency
WHERE NOT proposed_agency_name = 'DEPARTMENT OF SANITATION'
;


COPY agency TO '/var/lib/postgresql/data/agency.csv';