{% macro create_column_type_category() %}
{% set sql %}
    DO $$ BEGIN
        CREATE TYPE "category" AS ENUM('Residential', 'Commercial', 'Manufacturing');
        {% do log("Column type 'category' created", info=True) %}
    EXCEPTION
        WHEN duplicate_object THEN null;
        {% do log("Column type 'category' already exists", info=True) %}
    END $$;
{% endset %}

{% do run_query(sql) %}
{% endmacro %}