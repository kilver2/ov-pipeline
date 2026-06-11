WITH ritten AS (
    SELECT * FROM {{ ref('fct_ritten') }}
)

SELECT
    dag_van_de_week,
    dag_naam,
    is_weekend,
    COUNT(rit_id) AS totaal_ritten
FROM ritten
GROUP BY dag_van_de_week, dag_naam, is_weekend
ORDER BY dag_van_de_week
