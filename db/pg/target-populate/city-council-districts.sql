TRUNCATE 
	city_council_district
	CASCADE;
	
\copy city_council_district FROM '/var/lib/postgresql/data/city_council_district.csv';