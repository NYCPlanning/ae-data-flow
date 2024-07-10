DROP TABLE IF EXISTS source_borough;
CREATE TABLE IF NOT EXISTS source_borough (
	"id" char(1) PRIMARY KEY NOT NULL,
	"title" text,
	"abbr" char(2)
);

DROP TABLE IF EXISTS source_land_use;
CREATE TABLE IF NOT EXISTS source_land_use (
	"id" char(2) PRIMARY KEY NOT NULL,
	"description" text,
	"color" char(9)
);

DROP TABLE IF EXISTS source_pluto;
CREATE TABLE IF NOT EXISTS "source_pluto" (
	"bbl" text PRIMARY KEY NOT NULL,
	"borough" char(2) NOT NULL,
	"block" text NOT NULL,
	"lot" text NOT NULL,
	"address" text,
	"land_use" char(2),
	"wkt" geometry(MULTIPOLYGON, 2263)
);
