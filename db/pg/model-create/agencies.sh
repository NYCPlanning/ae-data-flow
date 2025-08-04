PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./flow/model-create/agencies.sql

PGPASSWORD=$TARGET_DATABASE_PASSWORD \
pg_dump --host=$TARGET_DATABASE_HOST  \
    --port=$TARGET_DATABASE_PORT \
    -U $TARGET_DATABASE_USER \
    -d $TARGET_DATABASE_NAME \
    -s \
    --no-owner \
    -t agency \
    -t managing_code \
    -t borough \
    -t community_district \
    -t cbbr_policy_area \
    -t cbbr_need_group \
    -t cbbr_need \
    -t cbbr_request \
    -t cbbr_option_cascade \
    -t capital_project \
    -t capital_project_fund \
    -t capital_commitment_type \
    -t capital_project_checkbook \
    -t agency_budget \
    -t budget_line \
    -t capital_commitment \
    -t capital_commitment_fund \
    --file ./data/agency_dump.sql

PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./data/agency_dump.sql
