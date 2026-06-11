WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_routes') }}
),

cleaned AS (
    SELECT
        {{ clean_empty_strings('route_id') }} AS route_id,
        {{ clean_empty_strings('agency_id') }} AS agency_id,
        {{ clean_empty_strings('route_short_name') }} AS route_short_name,
        {{ clean_empty_strings('route_long_name') }} AS route_long_name,
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
),

deduped AS (
    {{ deduplicate('cleaned', 'route_id', 'route_id') }}
)

SELECT * FROM deduped