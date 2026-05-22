TRUNCATE
  data_source
CASCADE;

INSERT INTO data_source (
    schema_name,
    dataset_name,
    version,
    retrieve_date
)
SELECT
    schema_name,
    dataset_name,
    v AS version,
    archive_date AS retrieve_date
FROM source_data_source;

COPY data_source TO '/var/lib/postgresql/data/data_source.csv';
