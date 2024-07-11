CREATE SERVER IF NOT EXISTS api_db
	FOREIGN DATA WRAPPER postgres_fdw
	OPTIONS (host %L, port %L, dbname %L);

CREATE USER MAPPING IF NOT EXISTS FOR postgres
	SERVER api_db
	OPTIONS (user %L, password %L);

IMPORT FOREIGN SCHEMA public
	EXCEPT (
		geography_columns,
		geometry_columns,
		spatial_ref_sys
	)
	FROM SERVER api_db INTO public;
