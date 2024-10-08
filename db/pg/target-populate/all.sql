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

\copy city_council_district FROM '/var/lib/postgresql/data/city_council_district.csv';
\copy community_district FROM '/var/lib/postgresql/data/community_district.csv';

\copy land_use FROM '/var/lib/postgresql/data/land_use.csv';
\copy tax_lot FROM '/var/lib/postgresql/data/tax_lot.csv';
\copy zoning_district FROM '/var/lib/postgresql/data/zoning_district.csv';
\copy zoning_district_class FROM '/var/lib/postgresql/data/zoning_district_class.csv';
\copy zoning_district_zoning_district_class FROM '/var/lib/postgresql/data/zoning_district_zoning_district_class.csv';

\copy managing_code FROM '/var/lib/postgresql/data/managing_code.csv';
\copy agency FROM '/var/lib/postgresql/data/agency.csv';
\copy capital_project FROM '/var/lib/postgresql/data/capital_project.csv';
\copy capital_project_fund FROM '/var/lib/postgresql/data/capital_project_fund.csv';
\copy capital_commitment_type FROM '/var/lib/postgresql/data/capital_commitment_type.csv';
\copy capital_project_checkbook FROM '/var/lib/postgresql/data/capital_project_checkbook.csv';
\copy agency_budget FROM '/var/lib/postgresql/data/agency_budget.csv';
\copy budget_line FROM '/var/lib/postgresql/data/budget_line.csv';
\copy capital_commitment FROM '/var/lib/postgresql/data/capital_commitment.csv';
\copy capital_commitment_fund FROM '/var/lib/postgresql/data/capital_commitment_fund.csv';