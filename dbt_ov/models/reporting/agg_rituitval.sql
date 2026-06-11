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
    COUNT(CASE WHEN f.uitzondering_type = 'Verwijderd' THEN 1 END) AS ritten_uitgevallen,
    COUNT(CASE WHEN f.uitzondering_type = 'Toegevoegd' THEN 1 END) AS ritten_toegevoegd,
    COUNT(f.rit_id) AS totaal_ritten,
    ROUND(COUNT(CASE WHEN f.uitzondering_type = 'Verwijderd' THEN 1 END) * 100.0 / NULLIF(COUNT(f.rit_id), 0), 2)
        AS uitval_percentage
FROM ritten AS f
LEFT JOIN routes AS r ON f.route_id = r.route_id
LEFT JOIN bureau AS b ON r.bureau_id = b.bureau_id
GROUP BY b.bureau_naam, r.vervoerstype
ORDER BY uitval_percentage DESC
