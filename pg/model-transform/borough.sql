TRUNCATE
	borough
	CASCADE;

CREATE TABLE IF NOT EXISTS flow_borough
	(LIKE borough INCLUDING ALL);

INSERT INTO borough
	SELECT
		borocode AS id,
		boroname AS title,
		CASE
			WHEN borocode = '1' THEN 'MN'
			WHEN borocode = '2' THEN 'BX'
			WHEN borocode = '3' THEN 'BK'
			WHEN borocode = '4' THEN 'QN'
			WHEN borocode = '5' THEN 'SI'
		END AS abbr,
		ST_Transform(wkt, 2263) AS li_ft,
  		ST_Transform(wkt, 3857) AS mercator_fill,
  		ST_Transform((ST_MaximumInscribedCircle(wkt)).center, 3857) AS mercator_label
	FROM source_borough;

COPY borough TO '/var/lib/postgresql/data/borough.csv';
