PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./flow/model-create/pluto.sql

PGPASSWORD=$TARGET_DATABASE_PASSWORD \
pg_dump --host=$TARGET_DATABASE_HOST  \
    --port=$TARGET_DATABASE_PORT \
    -U $TARGET_DATABASE_USER \
    -d $TARGET_DATABASE_NAME \
    -s \
    --no-owner \
    -t borough \
    -t land_use \
    -t tax_lot \
    -t zoning_district \
    -t zoning_district_class \
    -t zoning_district_zoning_district_class \
    --file ./data/pluto_dump.sql

PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./data/pluto_dump.sql
