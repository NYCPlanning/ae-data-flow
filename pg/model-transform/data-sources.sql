TRUNCATE
  data_source
CASCADE;

INSERT INTO data_source (
    schema_name,
    dataset_name,
    version,
    retrieve_date,
    url
)
SELECT
    schema_name,
    dataset_name,
    v AS version,
    archive_date AS retrieve_date,
    url
FROM source_data_source;

COPY data_source TO '/var/lib/postgresql/data/data_source.csv';
