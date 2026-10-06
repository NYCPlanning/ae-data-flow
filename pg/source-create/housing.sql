DROP TABLE IF EXISTS
	source_housing_growth_cd,
	source_housing_growth_nta
	CASCADE;

CREATE TABLE IF NOT EXISTS source_housing_growth_cd (
	"geography_id" char(3) NOT NULL,
	"units_2020_census" integer,
	"units_2020" integer,
	"completed_units_2016_2025" integer,
	"completed_units_2021_2025" integer, -- will be changed from _2025 to _current
	"units_2025" integer,
	"projected_completed_units_2026_2035" integer,
	"projected_units_2035" integer
);

CREATE TABLE IF NOT EXISTS source_housing_growth_nta (
	"geography_id" char(6) NOT NULL,
	"units_2020_census" integer,
	"units_2020" integer,
	"completed_units_2016_2025" integer,
	"completed_units_2021_2025" integer, -- will be changed from _2025 to _current
	"units_2025" integer,
	"projected_completed_units_2026_2035" integer,
	"projected_units_2035" integer
);