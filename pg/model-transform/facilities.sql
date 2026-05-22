TRUNCATE
    facility_operator,
    facility_type,
    facility_subgroup,
    facility_group,
    facility_domain
RESTART IDENTITY
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

INSERT INTO facility_domain (name, description)
SELECT DISTINCT
    "category" as name,
    "description" as description
FROM source_facility_category;

INSERT INTO facility_group (name, description, facility_domain_id)
SELECT DISTINCT
    source_facility_group.group as name,
    source_facility_group.description as description,
    facility_domain.id as facility_domain_id
FROM source_facility_group
LEFT JOIN source_facility ON LOWER(source_facility."FACGROUP") = LOWER(source_facility_group.group)
LEFT JOIN facility_domain ON LOWER(facility_domain.name) = LOWER(source_facility."FACDOMAIN");

INSERT INTO facility_subgroup (name, description, facility_group_id)
SELECT DISTINCT
    source_facility_subgroup.subgroup as name,
    source_facility_subgroup.description as description,
    facility_group.id as facility_group_id
FROM source_facility_subgroup
RIGHT JOIN source_facility ON LOWER(source_facility."FACSUBGRP") = LOWER(source_facility_subgroup.subgroup)
LEFT JOIN facility_group ON LOWER(facility_group.name) = LOWER(source_facility."FACGROUP");

INSERT INTO facility_type (name, facility_subgroup_id)
SELECT DISTINCT
    source_facility."FACTYPE" as name,
    facility_subgroup.id as facility_subgroup_id
FROM source_facility
LEFT JOIN facility_subgroup ON LOWER(source_facility."FACSUBGRP") = LOWER(facility_subgroup.name);
    
COPY facility_operator TO '/var/lib/postgresql/data/facility_operator.csv';
COPY facility_domain TO '/var/lib/postgresql/data/facility_domain.csv';
COPY facility_group TO '/var/lib/postgresql/data/facility_group.csv';
COPY facility_subgroup TO '/var/lib/postgresql/data/facility_subgroup.csv';
COPY facility_type TO '/var/lib/postgresql/data/facility_type.csv';
