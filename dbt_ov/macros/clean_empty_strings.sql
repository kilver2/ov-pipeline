-- macros/clean_empty_strings.sql
{% macro clean_empty_strings(column_name) %}
    NULLIF(TRIM({{ column_name }}), '')
{% endmacro %}