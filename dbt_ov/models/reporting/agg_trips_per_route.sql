WITH fct AS (
    SELECT * FROM {{ ref('fct_trips') }}
),

routes AS (
    SELECT * FROM {{ ref('dim_routes') }}
)

SELECT
    r.route_short_name,
    r.route_long_name,
    r.route_type,
    COUNT(f.trip_id) AS total_trips
FROM fct f
LEFT JOIN routes r ON f.route_id = r.route_id
GROUP BY r.route_short_name, r.route_long_name, r.route_type
ORDER BY total_trips DESC