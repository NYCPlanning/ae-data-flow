CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER IF NOT EXISTS api_db
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'ae-zoning-api-db-1', port '5432', dbname 'zoning');

CREATE USER MAPPING IF NOT EXISTS FOR postgres
	SERVER api_db
	OPTIONS (user 'postgres', password 'postgres');

IMPORT FOREIGN SCHEMA public 
  LIMIT TO (
    borough,
    land_use,
    tax_lot,
    zoning_district,
    zoning_district_class,
    zoning_district_zoning_district_class
  )
	FROM SERVER api_db INTO public;
