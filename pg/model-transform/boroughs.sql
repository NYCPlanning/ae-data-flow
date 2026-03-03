TRUNCATE
	borough
	CASCADE;

ALTER TABLE source_borough
    ADD COLUMN IF NOT EXISTS
        abbr char(2);

-- The (borough) boundaries are part of CSCL and require a schema change which must be approved by the governing committee. It has been determined that adding borough abbreviations to the data source is not feasible.

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
    abbr,
    li_ft,
    mercator_fill,
    mercator_label
)
SELECT
	boro_code,
	boro_name,
	abbr,
	ST_Transform(wkt, 2263) AS li_ft,
    ST_Transform(wkt, 3857) AS mercator_fill,
    ST_Transform((ST_MaximumInscribedCircle(wkt)).center, 3857) AS mercator_label
FROM source_borough
ORDER BY boro_code ASC;

COPY borough TO '/var/lib/postgresql/data/borough.csv';
