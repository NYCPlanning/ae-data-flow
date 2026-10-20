DROP TABLE IF EXISTS
  source_facility_category,
  source_facility_group,
  source_facility_subgroup,
	source_facility
	CASCADE;

CREATE TABLE IF NOT EXISTS source_facility (
  "asset_id"  text,
  "record_type"  text,
  "facility_name"  text,
  "address_number"  text,
  "street_name"  text,
  "address"  text,
  "city"  text,
  "zip_code"  text,
  "facility_type"  text,
  "facility_subgroup"  text,
  "facility_group"  text,
  "facility_domain"  text,
  "service_area"  text,
  "operating_entity_name"  text,
  "operating_entity_abbreviation"  text,
  "operator_type"  text,
  "oversight_agency_name"  text,
  "oversight_agency_abbreviation"  text,
  "oversight_agency_level"  text,
  "capacity"  numeric,
  "capacity_unit_type"  text,
  "fcs_score_total"  numeric,
  "fcs_letter_grade_total"  char(1),
  "fcs_score_architectural"  numeric,
  "fcs_letter_grade_architectural"  char(1),
  "fcs_score_systems"  numeric,
  "fcs_letter_grade_systems"  char(1),
  "fcs_assessment_year"  numeric,
  "fcs_assessment_month"  char(2),
  "fcs_assessment_date" date,
  "borough"  text,
  "borough_code"  char(1),
  "bin"  text,
  "bbl"  text,
  "latitude"  float,
  "longitude"  float,
  "x_coordinate"  float,
  "y_coordinate"  float,
  "community_district"  char(3),
  "nta_2010"  char(4),
  "nta_2020"  char(6),
  "city_council_district"  numeric,
  "census_tract_2010"  char(6),
  "census_tract_2020"  char(6),
  "school_district"  char(2),
  "police_precinct"  numeric,
  "data_source_file"  text,
  "uid"  text
);

CREATE TABLE IF NOT EXISTS source_facility_category (
  "id" numeric,
  "short_name" text,
  "category" text,
  "description" text
);

CREATE TABLE IF NOT EXISTS source_facility_group (
  "id" text,
  "group" text,
  "description" text
);

CREATE TABLE IF NOT EXISTS source_facility_subgroup (
  "id" text,
  "subgroup" text,
  "description" text
);