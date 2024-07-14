PGPASSWORD=$TARGET_DATABASE_PASSWORD \
psql --host=$TARGET_DATABASE_HOST  \
    --port=$TARGET_DATABASE_PORT \
    -U $TARGET_DATABASE_USER \
    -d $TARGET_DATABASE_NAME \
    --single-transaction \
    --file ./repopulate/target-repopulate.sql