-- TODO: parameterize
CREATE SERVER IF NOT EXISTS api_db
	FOREIGN DATA WRAPPER postgres_fdw
	OPTIONS (host 'ae-zoning-api-db-1', port '5432', dbname 'zoning');

CREATE USER MAPPING IF NOT EXISTS FOR postgres
	SERVER api_db
	OPTIONS (user 'postgres', password 'postgres');

IMPORT FOREIGN SCHEMA public
	EXCEPT (
		geography_columns,
		geometry_columns,
		spatial_ref_sys
	)
	FROM SERVER api_db INTO public;
