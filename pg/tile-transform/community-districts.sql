TRUNCATE
    tile_community_district
    CASCADE;

INSERT INTO tile_community_district (
    "borocd",
    "boro_district",
    "boroughIdCommunityDistrictId",
    "boroughAbbr",
	"fill",
	"label"
)
SELECT
	community_district.borough_id || community_district.id AS "borocd",
	borough.title || ' ' || community_district.id::integer % 100 AS "borough_district",
	community_district.borough_id || community_district.id AS "boroughIdCommunityDistrictId",
	borough.abbr AS "boroughAbbr",
	ST_Transform(community_district.mercator_fill, 4326) AS "fill",
	ST_Transform(community_district.mercator_label, 4326) AS "label"
FROM community_district
LEFT JOIN borough
	ON borough.id = community_district.borough_id
WHERE community_district.id::integer % 100 < 20;
