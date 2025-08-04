PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./flow/model-create/community-districts.sql

PGPASSWORD=$TARGET_DATABASE_PASSWORD \
pg_dump --host=$TARGET_DATABASE_HOST  \
    --port=$TARGET_DATABASE_PORT \
    -U $TARGET_DATABASE_USER \
    -d $TARGET_DATABASE_NAME \
    -s \
    --no-owner \
    -t borough \
    -t community_district \
    -t managing_code \
    -t agency \
    -t cbbr_policy_area \
    -t cbbr_need_group \
    -t cbbr_agency_need_group \
    -t cbbr_need \
    -t cbbr_agency_need \
    -t cbbr_request \
    -t cbbr_agency_need_request \
    --file ./data/community-districts_dump.sql

PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./data/community-districts_dump.sql
