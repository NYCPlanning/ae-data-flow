CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS tax_lot CASCADE;
CREATE TABLE IF NOT EXISTS "tax_lot" (
	"bbl" char(10) PRIMARY KEY NOT NULL,
	"borough_id" char(1) NOT NULL,
	"block" text NOT NULL,
	"lot" text NOT NULL,
	"address" text,
	"land_use_id" char(2),
	"wgs84" geography(multiPolygon, 4326) NOT NULL,
	"li_ft" geometry(multiPolygon,2263) NOT NULL
);

DO $$ BEGIN
 ALTER TABLE "tax_lot" ADD CONSTRAINT "tax_lot_borough_id_borough_id_fk" FOREIGN KEY ("borough_id") REFERENCES "borough"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "tax_lot" ADD CONSTRAINT "tax_lot_land_use_id_land_use_id_fk" FOREIGN KEY ("land_use_id") REFERENCES "land_use"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DROP TABLE IF EXISTS zoning_district CASCADE;
CREATE TABLE IF NOT EXISTS "zoning_district" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"label" text NOT NULL,
	"wgs84" geography(multiPolygon, 4326) NOT NULL,
	"li_ft" geometry(multiPolygon,2263) NOT NULL
);

DROP TABLE IF EXISTS zoning_district_zoning_district_class CASCADE;
CREATE TABLE IF NOT EXISTS "zoning_district_zoning_district_class" (
	"zoning_district_id" uuid NOT NULL,
	"zoning_district_class_id" text NOT NULL
);

DO $$ BEGIN
 ALTER TABLE "zoning_district_zoning_district_class" ADD CONSTRAINT "zoning_district_zoning_district_class_zoning_district_id_zoning_district_id_fk" FOREIGN KEY ("zoning_district_id") REFERENCES "zoning_district"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "zoning_district_zoning_district_class" ADD CONSTRAINT "zoning_district_zoning_district_class_zoning_district_class_id_zoning_district_class_id_fk" FOREIGN KEY ("zoning_district_class_id") REFERENCES "zoning_district_class"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
