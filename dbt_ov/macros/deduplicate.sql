{% macro deduplicate(model, partition_by, order_by) %}
    SELECT *
    FROM {{ model }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY {{ partition_by }}
        ORDER BY {{ order_by }}
    ) = 1
{% endmacro %}