TRUNCATE
  data_source
CASCADE;

  \copy data_source FROM '/var/lib/postgresql/data/data_source.csv';