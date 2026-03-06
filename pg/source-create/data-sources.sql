DROP TABLE IF EXISTS
  source_data_sources,
  CASCADE;

CREATE TABLE IF NOT EXISTS source_data_sources (
  schema_name text,
  dataset_name text,
  v text,
  file_type text
);