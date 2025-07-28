TRUNCATE
    agency
    CASCADE;

INSERT INTO agency
SELECT DISTINCT
    managing_agency_acronym as initials,
    managing_agency as name
FROM source_agency
WHERE NOT managing_agency = 'DEPARTMENT OF SANITATION'
;


COPY agency TO '/var/lib/postgresql/data/agency.csv';