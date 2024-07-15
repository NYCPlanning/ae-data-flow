TRUNCATE 
	city_council_district,
	community_district
	CASCADE;
	
\copy borough FROM '/var/lib/postgresql/data/borough.csv';
\copy land_use FROM '/var/lib/postgresql/data/land_use.csv';
\copy tax_lot FROM '/var/lib/postgresql/data/tax_lot.csv';
