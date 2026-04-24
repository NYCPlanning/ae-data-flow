TRUNCATE
  census_tract
  CASCADE;

  \copy census_tract FROM '/var/lib/postgresql/data/census_tract.csv';