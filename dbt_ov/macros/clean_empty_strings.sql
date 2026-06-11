{% macro clean_empty_strings(column_name) %}
    NULLIF(TRIM(CAST({{ column_name }} AS STRING)), '')
{% endmacro %}