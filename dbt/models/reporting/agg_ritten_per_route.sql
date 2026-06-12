WITH ritten AS (
    SELECT * FROM {{ ref('fct_ritten') }}
),

routes AS (
    SELECT * FROM {{ ref('dim_routes') }}
)

SELECT
    r.route_korte_naam,
    r.route_lange_naam,
    r.vervoerstype,
    COUNT(f.rit_id) AS totaal_ritten
FROM ritten AS f
LEFT JOIN routes AS r ON f.route_id = r.route_id
GROUP BY r.route_korte_naam, r.route_lange_naam, r.vervoerstype
ORDER BY totaal_ritten DESC
