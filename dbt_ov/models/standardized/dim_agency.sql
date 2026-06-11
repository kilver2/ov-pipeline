WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_agency') }}
),

cleaned AS (
    SELECT
        agency_id,
        agency_name,
        agency_url,
        agency_timezone
    FROM source
    WHERE agency_id IS NOT NULL
)

SELECT * FROM cleaned