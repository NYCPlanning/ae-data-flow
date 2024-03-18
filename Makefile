ifneq (,$(wildcard ./.env))
    include .env
    export
endif

SHELL := /bin/bash

hello:
	echo "hewwo world"

csvs:
	@mc alias set spaces $(DO_SPACES_ENDPOINT) $(DO_SPACES_ACCESS_KEY_ID) $(DO_SPACES_SECRET_ACCESS_KEY)
	@mc cp spaces/$(DO_SPACES_BUCKET_DISTRIBUTIONS)/dcp_pluto/23v3/pluto.csv pluto.csv
	@mc cp spaces/$(DO_SPACES_BUCKET_DISTRIBUTIONS)/dcp_pluto/23v3/attachments/zoning_districts.csv zoning_districts.csv
	@mc cp spaces/$(DO_SPACES_BUCKET_DISTRIBUTIONS)/dcp_pluto/23v3/attachments/source_data_versions.csv source_data_versions.csv

load:
	@export BUILD_ENGINE_SERVER=postgresql://$(BUILD_ENGINE_USER):$(BUILD_ENGINE_PASSWORD)@$(BUILD_ENGINE_HOST):$(BUILD_ENGINE_PORT)
	@export BUILD_ENGINE_URI=$(BUILD_ENGINE_SERVER)/$(BUILD_ENGINE_DB)
	@psql $(BUILD_ENGINE_URI) \
	--set ON_ERROR_STOP=1 --single-transaction --quiet \
	--file sql/load_sources.sql \
	--variable SCHEMA_NAME=$(BUILD_ENGINE_SCHEMA)
	@psql $(BUILD_ENGINE_URI) \
	--set ON_ERROR_STOP=1 --single-transaction --quiet \
	--file create_tables.sql \
	--variable SCHEMA_NAME=$(BUILD_ENGINE_SCHEMA)
	@psql $(BUILD_ENGINE_URI) \
	--set ON_ERROR_STOP=1 --single-transaction --quiet \
	--file import_tables.sql \
	--variable SCHEMA_NAME=$(BUILD_ENGINE_SCHEMA)
	