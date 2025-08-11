PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./flow/model-create/boroughs.sql

PGPASSWORD=$TARGET_DATABASE_PASSWORD \
pg_dump --host=$TARGET_DATABASE_HOST  \
    --port=$TARGET_DATABASE_PORT \
    -U $TARGET_DATABASE_USER \
    -d $TARGET_DATABASE_NAME \
    -s \
    --no-owner \
    -t borough \
    -t managing_code \
    -t agency \
    -t community_district \
    -t cbbr_policy_area \
    -t cbbr_need_group \
    -t cbbr_need \
    -t cbbr_request \
    -t cbbr_options_cascade \
    -t land_use \
    -t tax_lot \
    -t zoning_district \
    -t zoning_district_class \
    -t zoning_district_zoning_district_class \
    --file ./data/borough_dump.sql

PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./data/borough_dump.sql
