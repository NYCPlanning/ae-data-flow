PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./flow/model-create/capital-planning.sql

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
	-t capital_project \
	-t capital_project_fund \
	-t capital_commitment_type \
	-t capital_project_checkbook \
	-t agency_budget \
	-t budget_line \
	-t capital_commitment \
	-t capital_commitment_fund \
    --file ./data/capital_planning_dump.sql

PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./data/capital_planning_dump.sql
