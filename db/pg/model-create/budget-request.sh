PGPASSWORD=$POSTGRES_PASSWORD \
psql --host=localhost \
    --port=5432 \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    --single-transaction \
    --file ./flow/model-create/budget-request.sql

# PGPASSWORD=$TARGET_DATABASE_PASSWORD \
# pg_dump --host=$TARGET_DATABASE_HOST  \
#     --port=$TARGET_DATABASE_PORT \
#     -U $TARGET_DATABASE_USER \
#     -d $TARGET_DATABASE_NAME \
#     -s \
#     --no-owner \
#     -t policy_area \
#     -t need_group \
#     -t type_br \
#     -t need \
#     -t request \
#     -t budget_request \
#     --file ./data/budget_request_dump.sql

# PGPASSWORD=$POSTGRES_PASSWORD \
# psql --host=localhost \
#     --port=5432 \
#     -U $POSTGRES_USER \
#     -d $POSTGRES_DB \
#     --single-transaction \
#     --file ./data/budget_request_dump.sql