WITH ritten AS (
    SELECT * FROM {{ ref('fct_ritten') }}
),

routes AS (
    SELECT * FROM {{ ref('dim_routes') }}
),

bureau AS (
    SELECT * FROM {{ ref('dim_bureau') }}
)

SELECT
    b.bureau_naam,
    r.vervoerstype,
    COUNT(f.rit_id) AS totaal_ritten
FROM ritten AS f
LEFT JOIN routes AS r ON f.route_id = r.route_id
LEFT JOIN bureau AS b ON r.bureau_id = b.bureau_id
GROUP BY b.bureau_naam, r.vervoerstype
