DROP TABLE IF EXISTS
  source_facility_category,
  source_facility_group,
  source_facility_subgroup,
	source_facility
	CASCADE;

CREATE TABLE IF NOT EXISTS source_facility (
  "FACNAME" text,
  "ADDRESSNUM" text,
  "STREETNAME" text,
  "ADDRESS" text,
  "CITY" text,
  "ZIPCODE" text,
  "FACTYPE" text,
  "FACSUBGRP" text,
  "FACGROUP" text,
  "FACDOMAIN" text,
  "SERVAREA" text,
  "OPNAME" text,
  "OPABBREV" text,
  "OPTYPE" text,
  "OVERAGENCY" text,
  "OVERABBREV" text,
  "OVERLEVEL" text,
  "CAPACITY" numeric,
  "CAPTYPE" text,
  "BORO" text,
  "BIN" text,
  "BBL" text,
  "LATITUDE" float,
  "LONGITUDE" float,
  "XCOORD" float,
  "YCOORD" float,
  "CD" char(3),
  "NTA2010" char(4),
  "NTA2020" char(6),
  "COUNCIL" numeric,
  "CT2010" char(6),
  "CT2020" char(6),
  "BOROCODE" char(1),
  "SCHOOLDIST" char(2),
  "POLICEPRCT" numeric,
  "DATASOURCE" text,
  "UID" text
);

CREATE TABLE IF NOT EXISTS source_facility_category (
  "id" text,
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