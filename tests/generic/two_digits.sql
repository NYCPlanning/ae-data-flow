{% test two_digits(model, column_name) %}
SELECT {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }} NOT SIMILAR TO '[0-9]{2}'
{% endtest %}