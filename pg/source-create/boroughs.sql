DROP TABLE IF EXISTS 
	source_borough
	CASCADE;

CREATE TABLE IF NOT EXISTS source_borough (
	id char(1) PRIMARY KEY NOT NULL CHECK (id SIMILAR TO '[1-9]'),
	title text,
	abbr char(2)
);
