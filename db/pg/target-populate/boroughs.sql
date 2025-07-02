TRUNCATE 
	borough,
	community_district,
	land_use,
	tax_lot,
	zoning_district,
  	zoning_district_class,
	zoning_district_zoning_district_class
	CASCADE;
	
\copy borough FROM '/var/lib/postgresql/data/borough.csv';
\copy community_district FROM '/var/lib/postgresql/data/community_district.csv';
\copy land_use FROM '/var/lib/postgresql/data/land_use.csv';
\copy tax_lot FROM '/var/lib/postgresql/data/tax_lot.csv';
\copy zoning_district FROM '/var/lib/postgresql/data/zoning_district.csv';
\copy zoning_district_class FROM '/var/lib/postgresql/data/zoning_district_class.csv';
\copy zoning_district_zoning_district_class FROM '/var/lib/postgresql/data/zoning_district_zoning_district_class.csv';