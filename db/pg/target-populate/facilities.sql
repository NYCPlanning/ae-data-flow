TRUNCATE
    facility_operator,
    facility_type,
    facility_subgroup,
    facility_group,
    facility_domain
    CASCADE;

\copy facility_operator FROM '/var/lib/postgresql/data/facility_operator.csv';
\copy facility_domain FROM '/var/lib/postgresql/data/facility_domain.csv';
\copy facility_group FROM '/var/lib/postgresql/data/facility_group.csv';
\copy facility_subgroup FROM '/var/lib/postgresql/data/facility_subgroup.csv';
\copy facility_type FROM '/var/lib/postgresql/data/facility_type.csv';