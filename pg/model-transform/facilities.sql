TRUNCATE
    facility_operator,
    facility_type,
    facility_subgroup,
    facility_group,
    facility_domain,
    facility
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
    source_facility.operating_entity_abbreviation as abbreviation,
    source_facility.operating_entity_name as name,
    source_facility.operator_type as type
FROM source_facility
WHERE source_facility.operating_entity_name IS NOT NULL;

INSERT INTO facility_operator
SELECT gen_random_uuid() as id, *
FROM facility_operator_all;

INSERT INTO facility_domain (id, short_name, name, description)
SELECT DISTINCT
    source_facility_category.id as id,
    source_facility_category.short_name as short_name,
    source_facility_category.category as name,
    source_facility_category.description as description
FROM source_facility_category;

INSERT INTO facility_group (name, description, facility_domain_id)
SELECT DISTINCT
    source_facility_group.group as name,
    source_facility_group.description as description,
    facility_domain.id as facility_domain_id
FROM source_facility_group
LEFT JOIN source_facility ON LOWER(source_facility.facility_group) = LOWER(source_facility_group.group)
LEFT JOIN facility_domain ON LOWER(facility_domain.name) = LOWER(source_facility.facility_domain);

INSERT INTO facility_subgroup (name, description, facility_group_id)
SELECT DISTINCT
    source_facility_subgroup.subgroup as name,
    source_facility_subgroup.description as description,
    facility_group.id as facility_group_id
FROM source_facility_subgroup
RIGHT JOIN source_facility ON LOWER(source_facility.facility_subgroup) = LOWER(source_facility_subgroup.subgroup)
LEFT JOIN facility_group ON LOWER(facility_group.name) = LOWER(source_facility.facility_group);

INSERT INTO facility_type (name, facility_subgroup_id)
SELECT DISTINCT
    source_facility.facility_type as name,
    facility_subgroup.id as facility_subgroup_id
FROM source_facility
LEFT JOIN facility_subgroup ON LOWER(source_facility.facility_subgroup) = LOWER(facility_subgroup.name);

INSERT INTO facility (
    name, 
    address,
    address_number,
    street_name, 
    city, 
    zip_code,
    facility_type_id,
    service_area,
    facility_operator_id,
    overseeing_agency_initials,
    capacity, 
    capacity_type,
    fcs_score_total,
    fcs_letter_grade_total,
    fcs_score_architectural,
    fcs_letter_grade_architectural,
    fcs_score_systems,
    fcs_letter_grade_systems,
    fcs_assessment_year,
    bin, 
    bbl, 
    li_ft, 
    mercator, 
    data_source_schema,
    id
)
SELECT DISTINCT
    source_facility.facility_name as name,
    source_facility.address as address,
    source_facility.address_number as address_number,
    source_facility.street_name as street_name,
    source_facility.city as city,
    source_facility.zip_code as zip_code,
    facility_type.id as facility_type_id,
    source_facility.service_area as service_area,
    facility_operator.id as facility_operator_id,
    agency.initials as overseeing_agency_initials,
    source_facility.capacity as capacity,
    source_facility.capacity_unit_type as capacity_type,
    source_facility.fcs_score_total as fcs_score_total,
    source_facility.fcs_letter_grade_total as fcs_letter_grade_total,
    source_facility.fcs_score_architectural as fcs_score_architectural,
    source_facility.fcs_letter_grade_architectural as fcs_letter_grade_architectural,
    source_facility.fcs_score_systems as fcs_score_systems,
    source_facility.fcs_letter_grade_systems as fcs_letter_grade_systems,
    source_facility.fcs_assessment_year as fcs_assessment_year,
    source_facility.bin as bin,
    source_facility.bbl as bbl,
    ST_SetSRID(ST_MakePoint(source_facility.x_coordinate, source_facility.y_coordinate), 2263) as li_ft,
    ST_Transform(ST_SetSRID(ST_MakePoint(source_facility.x_coordinate, source_facility.y_coordinate), 2263), 3857) as mercator,
    data_source.schema_name as data_source_schema,
    source_facility.uid as id
FROM source_facility
LEFT JOIN facility_type ON source_facility.facility_type = facility_type.name
LEFT JOIN facility_operator ON source_facility.operating_entity_name = facility_operator.name AND source_facility.operating_entity_abbreviation = facility_operator.abbreviation
LEFT JOIN agency ON source_facility.oversight_agency_abbreviation = agency.initials
LEFT JOIN data_source ON source_facility.data_source_file = data_source.schema_name
;
    
COPY facility_operator TO '/var/lib/postgresql/data/facility_operator.csv';
COPY facility_domain TO '/var/lib/postgresql/data/facility_domain.csv';
COPY facility_group TO '/var/lib/postgresql/data/facility_group.csv';
COPY facility_subgroup TO '/var/lib/postgresql/data/facility_subgroup.csv';
COPY facility_type TO '/var/lib/postgresql/data/facility_type.csv';
COPY facility TO '/var/lib/postgresql/data/facility.csv';
