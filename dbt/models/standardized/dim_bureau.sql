-- Inladen Agency raw
WITH bron AS (
    SELECT * FROM {{ source('raw', 'raw_agency') }}
),

-- Cleaning dmv vernederlandsing
gecleand AS (
    SELECT
        {{ clean_empty_strings('agency_id') }} AS bureau_id,
        {{ clean_empty_strings('agency_name') }} AS bureau_naam,
        {{ clean_empty_strings('agency_url') }} AS bureau_url,
        {{ clean_empty_strings('agency_timezone') }} AS bureau_tijdzone
    FROM bron
    WHERE agency_id IS NOT NULL
),

-- Deduplication op bureau_id
ontdubbeld AS (
    {{ deduplicate('gecleand', 'bureau_id', 'bureau_id') }}
)

SELECT * FROM ontdubbeld
