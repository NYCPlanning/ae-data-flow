	CREATE EXTENSION IF NOT EXISTS postgres_fdw;

	CREATE SERVER IF NOT EXISTS api_db
	FOREIGN DATA WRAPPER postgres_fdw
	OPTIONS (host 'ae-zoning-api-db-1', port '5432', dbname 'zoning');

CREATE USER MAPPING FOR postgres
	SERVER api_db
	OPTIONS (user 'postgres', password 'postgres');
	
IMPORT FOREIGN SCHEMA public LIMIT TO (tax_lot)
	FROM SERVER api_db INTO public;
