TRUNCATE
	borough	
	CASCADE;

INSERT INTO borough
	SELECT
		id,
		title,
		abbr
	FROM source_borough;
	
COPY borough TO '/var/lib/postgresql/data/borough.csv';
