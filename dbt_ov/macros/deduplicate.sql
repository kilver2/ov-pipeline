{% macro deduplicate(relation, partition_by, order_by) %}
    SELECT *
    FROM {{ relation }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY {{ partition_by }}
        ORDER BY {{ order_by }}
    ) = 1
{% endmacro %}