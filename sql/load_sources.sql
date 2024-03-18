DROP TABLE IF EXISTS source_pluto;
DROP INDEX IF EXISTS pluto_geom_idx;
CREATE TABLE IF NOT EXISTS "source_pluto" (
	"bbl" text PRIMARY KEY NOT NULL,
	"borough" char(2) NOT NULL,
	"block" text NOT NULL,
	"lot" text NOT NULL,
	"address" text,
	"land_use" char(2),
	"wkt" geometry(MULTIPOLYGON, 2263)
);
CREATE INDEX pluto_geom_idx
  ON source_pluto
  USING GIST (wkt);

\COPY source_pluto ("wkt", "borough", "block", "lot", "address", "land_use", "bbl") FROM './pluto.csv' DELIMITER ',' CSV HEADER;


DROP TABLE IF EXISTS source_zoning_districts;
DROP INDEX IF EXISTS zoning_districts_geom_idx;
CREATE TABLE IF NOT EXISTS "source_zoning_districts" (
	"zonedist" text NOT NULL,
	"shape_leng" float,
	"shape_area" float,
	"wkt" geometry(MULTIPOLYGON, 4326)
);
CREATE INDEX zoning_districts_geom_idx
  ON source_zoning_districts
  USING GIST (wkt);

\COPY source_zoning_districts ("wkt", "zonedist", "shape_leng", "shape_area") FROM './zoning_districts.csv' DELIMITER ',' CSV HEADER;