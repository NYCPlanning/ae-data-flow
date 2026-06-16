DROP TABLE IF EXISTS
  source_facility_category,
  source_facility_group,
  source_facility_subgroup,
	source_facility
	CASCADE;

CREATE TABLE IF NOT EXISTS source_facility_sgr (
  "assetid" text,
  "rectype" text,
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
  "sgrnum" numeric,
  "sgrltr" text,
  "sgrnumarc" numeric,
  "sgrltrarc" text,
  "sgrnumsys" numeric,
  "sgrltrsys" text,
  "sgrasmtyr" numeric,
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
  "uid" text
);

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
  "uid" text
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