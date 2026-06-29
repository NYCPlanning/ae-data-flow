DROP TABLE IF EXISTS
  source_data_source
CASCADE;

CREATE TABLE IF NOT EXISTS source_data_source (
  schema_name text,
  dataset_name text,
  v text,
  file_type text,
  archive_date date,
  url text
);