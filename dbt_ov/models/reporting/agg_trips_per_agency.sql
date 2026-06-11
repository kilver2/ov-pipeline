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
    COUNT(f.trip_id) AS total_trips
FROM fct f
LEFT JOIN routes r ON f.route_id = r.route_id
LEFT JOIN agency a ON r.agency_id = a.agency_id
GROUP BY a.agency_name, r.route_type