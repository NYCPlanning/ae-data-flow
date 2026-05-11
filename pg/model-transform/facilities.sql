TRUNCATE
    facility_operator
    CASCADE;

DROP TABLE IF EXISTS facility_operator_all CASCADE;

CREATE TABLE IF NOT EXISTS facility_operator_all (
    abbreviation text,
    name text,
    type text
);

INSERT INTO facility_operator_all (
    abbreviation, 
    name, 
    type
)
SELECT DISTINCT
    "OPABBREV" as abbreviation,
    "OPNAME" as name,
    "OPTYPE" as type
FROM source_facility
WHERE "OPNAME" IS NOT NULL;

INSERT INTO facility_operator
SELECT gen_random_uuid() as id, *
FROM facility_operator_all;

COPY facility_operator TO '/var/lib/postgresql/data/facility_operator.csv';