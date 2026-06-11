WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_agency') }}
),

cleaned AS (
    SELECT
        {{ clean_empty_strings('agency_id') }} AS agency_id,
        {{ clean_empty_strings('agency_name') }} AS agency_name,
        {{ clean_empty_strings('agency_url') }} AS agency_url,
        {{ clean_empty_strings('agency_timezone') }} AS agency_timezone
    FROM source
    WHERE agency_id IS NOT NULL
),

deduped AS (
    {{ deduplicate('cleaned', 'agency_id', 'agency_id') }}
)

SELECT * FROM deduped