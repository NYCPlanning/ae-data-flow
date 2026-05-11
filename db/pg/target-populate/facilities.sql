TRUNCATE
    facility_operator
    CASCADE;

\copy facility_operator FROM '/var/lib/postgresql/data/facility_operator.csv';