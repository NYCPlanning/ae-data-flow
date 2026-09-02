TRUNCATE
    housing_growth_cd,
    housing_growth_nta
    CASCADE;

\copy housing_growth_cd FROM '/var/lib/postgresql/data/housing_growth_cd.csv';
\copy housing_growth_nta FROM '/var/lib/postgresql/data/housing_growth_nta.csv';