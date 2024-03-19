{% test one_to_five_digits(model, column_name) %}
SELECT {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }} NOT SIMILAR TO '[0-9]{1,5}'
{% endtest %}