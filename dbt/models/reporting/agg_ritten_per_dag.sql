-- Inladen ritten
WITH ritten AS (
    SELECT * FROM {{ ref('fct_ritten') }}
)

-- agg voor het totaal aantal ritten per dag vd week
SELECT
    dag_van_de_week,
    dag_naam,
    is_weekend,
    COUNT(rit_id) AS totaal_ritten
FROM ritten
GROUP BY dag_van_de_week, dag_naam, is_weekend
ORDER BY dag_van_de_week
