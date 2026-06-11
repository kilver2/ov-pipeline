WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_stops') }}
),

cleaned AS (
    SELECT
        stop_id,
        stop_name,
        stop_lat::DOUBLE AS stop_lat,
        stop_lon::DOUBLE AS stop_lon,
        platform_code,
        parent_station,
        location_type
    FROM source
    WHERE stop_id IS NOT NULL
    AND stop_name IS NOT NULL
)

SELECT * FROM cleaned