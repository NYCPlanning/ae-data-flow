TRUNCATE 
	city_council_district,
	community_district
	CASCADE;
	
\copy city_council_district FROM '/var/lib/postgresql/data/city_council_district.csv';
\copy community_district FROM '/var/lib/postgresql/data/community_district.csv';
