CREATE TABLE IF NOT EXISTS "borough" (
	"id" char(1) PRIMARY KEY NOT NULL,
	"title" text NOT NULL,
	"abbr" text NOT NULL
);

CREATE TABLE IF NOT EXISTS "land_use" (
	"id" char(2) PRIMARY KEY NOT NULL,
	"description" text NOT NULL,
	"color" char(9) NOT NULL
);