TRUNCATE
    agency,
    managing_code
    CASCADE;

INSERT INTO agency (initials, name, oversight_level)
SELECT DISTINCT
    managing_agency_acronym as initials,
    managing_agency as name,
    NULLIF(overlevel, '') AS oversight_level
FROM source_agency;

INSERT INTO agency (initials, name)
    VALUES
        ('OCA', 'Office of Court Administration'),
        -- Community board budget requests list "other" as an agency option
        ('OTH', 'Other');
-- NYCRGB and SUNY have blank names the below is updating the table to include the names
UPDATE agency SET name = 'NYC Rent Guidelines Board' WHERE initials = 'NYCRGB';
UPDATE agency SET name = 'State University of New York' WHERE initials = 'SUNY';
INSERT INTO managing_code (id)
SELECT DISTINCT
	agency_code AS id
FROM source_agency
WHERE
	agency_code IS NOT NULL
	AND agency_code != '04A';

-- MOME agency code that is NULL in source data
INSERT INTO managing_code (id)
    VALUES ('859');

COPY agency TO '/var/lib/postgresql/data/agency.csv';
COPY managing_code TO '/var/lib/postgresql/data/managing_code.csv';
