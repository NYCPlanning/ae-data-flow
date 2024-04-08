TRUNCATE
	borough	
	CASCADE;

CREATE TABLE IF NOT EXISTS flow_borough 
	(LIKE borough INCLUDING ALL);

INSERT INTO borough
	SELECT
		id,
		title,
		abbr
	FROM source_borough;
	
COPY borough TO '/var/lib/postgresql/data/borough.csv';
