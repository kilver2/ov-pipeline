WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_calendar_dates') }}
),

cleaned AS (
    SELECT DISTINCT
        date,
        TO_DATE(date, 'yyyyMMdd') AS date_parsed,
        DAYOFWEEK(TO_DATE(date, 'yyyyMMdd')) AS day_of_week,
        CASE DAYOFWEEK(TO_DATE(date, 'yyyyMMdd'))
            WHEN 1 THEN 'Zondag'
            WHEN 2 THEN 'Maandag'
            WHEN 3 THEN 'Dinsdag'
            WHEN 4 THEN 'Woensdag'
            WHEN 5 THEN 'Donderdag'
            WHEN 6 THEN 'Vrijdag'
            WHEN 7 THEN 'Zaterdag'
        END AS day_of_week_name,
        WEEKOFYEAR(TO_DATE(date, 'yyyyMMdd')) AS week_number,
        MONTH(TO_DATE(date, 'yyyyMMdd')) AS month,
        YEAR(TO_DATE(date, 'yyyyMMdd')) AS year,
        CASE WHEN DAYOFWEEK(TO_DATE(date, 'yyyyMMdd')) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend
    FROM source
)

SELECT * FROM cleaned