DROP TABLE IF EXISTS
  source_facility_category,
  source_facility_group,
  source_facility_subgroup,
	source_facility
	CASCADE;

CREATE TABLE IF NOT EXISTS source_facility (
  "facname" text,
  "addressnum" text,
  "streetname" text,
  "address" text,
  "city" text,
  "zipcode" text,
  "factype" text,
  "facsubgrp" text,
  "facgroup" text,
  "facdomain" text,
  "servarea" text,
  "opname" text,
  "opabbrev" text,
  "optype" text,
  "overagency" text,
  "overabbrev" text,
  "overlevel" text,
  "capacity" numeric,
  "captype" text,
  "boro" text,
  "bin" text,
  "bbl" text,
  "latitude" float,
  "longitude" float,
  "xcoord" float,
  "ycoord" float,
  "cd" char(3),
  "nta2010" char(4),
  "nta2020" char(6),
  "council" numeric,
  "ct2010" char(6),
  "ct2020" char(6),
  "borocode" char(1),
  "schooldist" char(2),
  "policeprct" numeric,
  "datasource" text,
  "rectype" text,
  "asset_id" text,
  "sgr_score_tot" numeric,
  "sgr_grade_tot" text,
  "sgr_score_arch" numeric,
  "sgr_grade_arch" text,
  "sgr_score_syst" numeric, 
  "sgr_grade_syst" text,
  "sgr_assmt_year" numeric,
  "uid" text
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