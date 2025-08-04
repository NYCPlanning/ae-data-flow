TRUNCATE
	borough,
	community_district,
	cbbr_policy_area,
    cbbr_need_group,
    cbbr_need,
    cbbr_request,
	land_use,
	tax_lot,
	zoning_district,
  	zoning_district_class,
	zoning_district_zoning_district_class
RESTART IDENTITY
CASCADE;

\copy borough FROM '/var/lib/postgresql/data/borough.csv';

\copy community_district FROM '/var/lib/postgresql/data/community_district.csv';

\copy cbbr_policy_area FROM '/var/lib/postgresql/data/cbbr_policy_area.csv';
\copy cbbr_need_group FROM '/var/lib/postgresql/data/cbbr_need_group.csv';
\copy cbbr_need FROM '/var/lib/postgresql/data/cbbr_need.csv';
\copy cbbr_request FROM '/var/lib/postgresql/data/cbbr_request.csv';
\copy cbbr_option_cascade FROM '/var/lib/postgresql/data/cbbr_option_cascade.csv';

\copy land_use FROM '/var/lib/postgresql/data/land_use.csv';
\copy tax_lot FROM '/var/lib/postgresql/data/tax_lot.csv';
\copy zoning_district FROM '/var/lib/postgresql/data/zoning_district.csv';
\copy zoning_district_class FROM '/var/lib/postgresql/data/zoning_district_class.csv';
\copy zoning_district_zoning_district_class FROM '/var/lib/postgresql/data/zoning_district_zoning_district_class.csv';
