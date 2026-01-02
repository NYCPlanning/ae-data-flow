DROP TABLE IF EXISTS
	tile_community_district
	CASCADE;

CREATE TABLE IF NOT EXISTS tile_community_district (
    "borocd" char(3), -- support carto / layers API
    "boro_district" text, -- support carto / layers API
    "boroughIdCommunityDistrictId" char(3), -- support zoning api
    "boroughAbbr" char(2),
	"fill" geography(GEOMETRY, 4326) NOT NULL,
	"label" geography(POINT, 4326) NOT NULL
);
