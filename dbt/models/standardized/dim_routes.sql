WITH bron AS (
    SELECT * FROM {{ source('raw', 'raw_routes') }}
),

gecleand AS (
    SELECT
        {{ clean_empty_strings('route_id') }} AS route_id,
        {{ clean_empty_strings('agency_id') }} AS bureau_id,
        {{ clean_empty_strings('route_short_name') }} AS route_korte_naam,
        {{ clean_empty_strings('route_long_name') }} AS route_lange_naam,
        CASE route_type
            WHEN '0' THEN 'Tram'
            WHEN '1' THEN 'Metro'
            WHEN '2' THEN 'Trein'
            WHEN '3' THEN 'Bus'
            WHEN '4' THEN 'Ferry'
            ELSE 'Onbekend'
        END AS vervoerstype
    FROM bron
    WHERE route_id IS NOT NULL
),

ontdubbeld AS (
    {{ deduplicate('gecleand', 'route_id', 'route_id') }}
)

SELECT * FROM ontdubbeld
