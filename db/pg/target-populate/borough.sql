TRUNCATE 
	borough
	CASCADE;
	
\copy borough FROM '/var/lib/postgresql/data/borough.csv';