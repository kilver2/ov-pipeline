WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_feestdagen') }}
),

cleaned AS (
    SELECT
        {{ clean_empty_strings('date') }} AS datum,
        {{ clean_empty_strings('localname') }} AS feestdag_naam,
        {{ clean_empty_strings('name') }} AS feestdag_naam_en,
        jaar::INT AS jaar,
        CASE WHEN fixed = 'true' THEN TRUE ELSE FALSE END AS is_vast
    FROM source
    WHERE date IS NOT NULL
)

SELECT * FROM cleaned