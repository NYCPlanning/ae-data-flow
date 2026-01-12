TRUNCATE
	borough
	CASCADE;

ALTER TABLE source_borough
    ADD COLUMN IF NOT EXISTS
        abbr char(2);

UPDATE source_borough
    SET
        abbr = CASE
            WHEN boro_code = '1' THEN 'MN'
            WHEN boro_code = '2' THEN 'BX'
            WHEN boro_code = '3' THEN 'BK'
            WHEN boro_code = '4' THEN 'QN'
            WHEN boro_code = '5' THEN 'SI'
        END;

INSERT INTO borough (
    id,
    title,
    abbr
)
SELECT
	boro_code,
	boro_name,
	abbr
FROM source_borough
ORDER BY boro_code ASC;

COPY borough TO '/var/lib/postgresql/data/borough.csv';
