TRUNCATE 
	community_district
	CASCADE;
	
\copy community_district FROM '/var/lib/postgresql/data/community_district.csv';
