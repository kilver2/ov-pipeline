-- Inladen feestdagen raw
WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_feestdagen') }}
),

-- Vernederlandsing en casting van jaar
cleaned AS (
    SELECT
        {{ clean_empty_strings('date') }} AS datum,
        {{ clean_empty_strings('localname') }} AS feestdag_naam,
        {{ clean_empty_strings('name') }} AS feestdag_naam_en,
        jaar::INT AS jaar,
        coalesce(fixed = 'true', FALSE) AS is_vast
    FROM source
    WHERE date IS NOT NULL
)

SELECT * FROM cleaned
