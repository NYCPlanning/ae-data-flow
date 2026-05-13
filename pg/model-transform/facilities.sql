TRUNCATE
    facility_operator
    CASCADE;

INSERT INTO facility_operator (
    id,
    abbreviation, 
    name, 
    type
)
SELECT DISTINCT
    gen_random_uuid() AS id,
    "OPABBREV" as abbreviation,
    "OPNAME" as name,
    "OPTYPE" as type
FROM source_facility;

COPY facility_operator TO '/var/lib/postgresql/data/facility_operator.csv';