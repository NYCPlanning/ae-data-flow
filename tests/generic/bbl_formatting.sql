{% test bbl_formatting(model, column_name) %}
SELECT {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }} NOT SIMILAR TO '[0-9]{10}\.00000000'
{% endtest %}