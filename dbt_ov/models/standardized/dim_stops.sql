WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_stops') }}
),

cleaned AS (
    SELECT
        {{ clean_empty_strings('stop_id') }} AS stop_id,
        {{ clean_empty_strings('stop_name') }} AS stop_name,
        stop_lat::DOUBLE AS stop_lat,
        stop_lon::DOUBLE AS stop_lon,
        {{ clean_empty_strings('platform_code') }} AS platform_code,
        {{ clean_empty_strings('parent_station') }} AS parent_station,
        {{ clean_empty_strings('location_type') }} AS location_type
    FROM source
    WHERE stop_id IS NOT NULL
    AND stop_name IS NOT NULL
),

deduped AS (
    {{ deduplicate('cleaned', 'stop_id', 'stop_id') }}
)

SELECT * FROM deduped