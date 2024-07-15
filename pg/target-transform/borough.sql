DROP TABLE IF EXISTS
	flow_borough
	CASCADE;

CREATE TABLE IF NOT EXISTS flow_borough 
	(LIKE borough INCLUDING ALL);

INSERT INTO flow_borough
	SELECT
		id,
		title,
		abbr
	FROM source_borough;
	
COPY flow_borough TO '/var/lib/postgresql/data/borough.csv';
