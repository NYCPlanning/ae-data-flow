TRUNCATE
    tile_community_district
    CASCADE;

INSERT INTO tile_community_district
SELECT
    borocd AS borough_id_community_district_id,
    ST_Transform(wkt, 4326) AS fill,
    ST_Transform((ST_MaximumInscribedCircle(wkt)).center, 4326) AS label
FROM source_community_district;
