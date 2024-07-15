TRUNCATE 
	borough,
	city_council_district,
	community_district,
	land_use,
	tax_lot,
	zoning_district,
  	zoning_district_class,
	zoning_district_zoning_district_class,
	managing_code,
	agency,
	capital_project,
	capital_project_fund,
	capital_commitment_type,
	agency_budget,
	budget_line,
	capital_commitment,
	capital_commitment_fund,
	capital_project_checkbook
	CASCADE;
	
\copy borough FROM '/var/lib/postgresql/data/borough.csv';
\copy land_use FROM '/var/lib/postgresql/data/land_use.csv';
\copy tax_lot FROM '/var/lib/postgresql/data/tax_lot.csv';
