{% test no_duplicates(model, column_name) %}
    SELECT {{ column_name }}
    FROM {{ model }}
    GROUP BY {{ column_name }}
    HAVING COUNT(*) > 1
{% endtest %}