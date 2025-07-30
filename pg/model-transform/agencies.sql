TRUNCATE
    agency,
    managing_code
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

INSERT INTO managing_code (id)
SELECT DISTINCT
	agency_code AS id
FROM source_agency
WHERE
	agency_code IS NOT NULL
	AND agency_code != '04A';

COPY agency TO '/var/lib/postgresql/data/agency.csv';
COPY managing_code TO '/var/lib/postgresql/data/managing_code.csv';
