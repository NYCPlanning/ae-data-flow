TRUNCATE
    tile_community_district
    CASCADE;

INSERT INTO tile_community_district
SELECT
    source_community_district.borocd AS borough_id_community_district_id,
	source_borough.abbr AS borough_abbr,
    ST_Transform(source_community_district.wkt, 4326) AS fill,
    ST_Transform((ST_MaximumInscribedCircle(source_community_district.wkt)).center, 4326) AS label
FROM source_community_district
LEFT JOIN source_borough
	ON SUBSTRING(source_community_district.borocd, 1,1) = source_borough.id;
