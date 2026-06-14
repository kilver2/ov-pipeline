-- Inladen stops raw
WITH bron AS (
    SELECT * FROM {{ source('raw', 'raw_stops') }}
),

-- Vernederlandsing, casting en rijen verwijderen waar geen stop-id
gecleand AS (
    SELECT
        {{ clean_empty_strings('stop_id') }} AS halte_id,
        {{ clean_empty_strings('stop_name') }} AS halte_naam,
        stop_lat::DOUBLE AS breedtegraad,
        stop_lon::DOUBLE AS lengtegraad,
        {{ clean_empty_strings('platform_code') }} AS perron_code,
        {{ clean_empty_strings('parent_station') }} AS hoofdstation,
        {{ clean_empty_strings('location_type') }} AS locatietype
    FROM bron
    WHERE
        stop_id IS NOT NULL
        AND stop_name IS NOT NULL
),

-- Deduplicaten op halte
ontdubbeld AS (
    {{ deduplicate('gecleand', 'halte_id', 'halte_id') }}
)

SELECT * FROM ontdubbeld
