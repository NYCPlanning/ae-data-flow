DROP TABLE IF EXISTS
    tile_community_district
    CASCADE;

CREATE TABLE IF NOT EXISTS tile_community_district (
    borough_id_community_district_id char(3) CHECK (borough_id_community_district_id SIMILAR TO '[0-9]{1,3}'),
    fill geometry(MULTIPOLYGON, 4326) NOT NULL,
    label geometry(POINT, 4326) NOT NULL
);
