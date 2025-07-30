TRUNCATE
    agency
    CASCADE;

INSERT INTO agency (initials, name)
SELECT DISTINCT
    managing_agency_acronym as initials,
    managing_agency as name
FROM source_agency;

INSERT INTO agency (initials, name)
    VALUES
        ('OCA', 'Office of Court Administration'),
        ('MTA', 'Metropolitan Transportation Authority');

COPY agency TO '/var/lib/postgresql/data/agency.csv';
