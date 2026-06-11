WITH fct AS (
    SELECT * FROM {{ ref('fct_trips') }}
),

routes AS (
    SELECT * FROM {{ ref('dim_routes') }}
),

agency AS (
    SELECT * FROM {{ ref('dim_agency') }}
)

SELECT
    a.agency_name,
    r.route_type,
    COUNT(CASE WHEN f.exception_type = 'Verwijderd' THEN 1 END) AS ritten_uitgevallen,
    COUNT(CASE WHEN f.exception_type = 'Toegevoegd' THEN 1 END) AS ritten_toegevoegd,
    COUNT(f.trip_id) AS total_trips,
    ROUND(COUNT(CASE WHEN f.exception_type = 'Verwijderd' THEN 1 END) * 100.0 / COUNT(f.trip_id), 2) AS uitval_percentage
FROM fct f
LEFT JOIN routes r ON f.route_id = r.route_id
LEFT JOIN agency a ON r.agency_id = a.agency_id
GROUP BY a.agency_name, r.route_type
ORDER BY uitval_percentage DESC