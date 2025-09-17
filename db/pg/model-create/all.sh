PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./flow/model-create/all.sql

PGPASSWORD=$TARGET_DATABASE_PASSWORD \
pg_dump --host=$TARGET_DATABASE_HOST  \
    --port=$TARGET_DATABASE_PORT \
    -U $TARGET_DATABASE_USER \
    -d $TARGET_DATABASE_NAME \
    -s \
    --no-owner \
    -t borough \
    -t city_council_district \
    -t community_district \
    -t land_use \
    -t tax_lot \
    -t zoning_district \
    -t zoning_district_class \
    -t zoning_district_zoning_district_class \
    -t managing_code \
    -t agency \
    -t cbbr_policy_area \
    -t cbbr_need_group \
    -t cbbr_need \
    -t cbbr_request \
    -t cbbr_option_cascade \
    -t cbbr_agency_category_response \
    -t community_board_budget_request \
    -t capital_project \
    -t capital_project_fund \
    -t capital_commitment_type \
    -t capital_project_checkbook \
    -t agency_budget \
    -t budget_line \
    -t capital_commitment \
    -t capital_commitment_fund \
    --file ./data/all_dump.sql

PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./data/all_dump.sql
