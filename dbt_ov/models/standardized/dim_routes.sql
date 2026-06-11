WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_routes') }}
),

cleaned AS (
    SELECT
        route_id,
        agency_id,
        route_short_name,
        route_long_name,
        CASE route_type
            WHEN '0' THEN 'Tram'
            WHEN '1' THEN 'Metro'
            WHEN '2' THEN 'Trein'
            WHEN '3' THEN 'Bus'
            WHEN '4' THEN 'Ferry'
            ELSE 'Onbekend'
        END AS route_type
    FROM source
    WHERE route_id IS NOT NULL
)

SELECT * FROM cleaned