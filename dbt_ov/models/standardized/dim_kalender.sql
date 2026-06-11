WITH bron AS (
    SELECT * FROM {{ source('raw', 'raw_calendar_dates') }}
),

gecleand AS (
    SELECT DISTINCT
        date AS datum,
        TO_DATE(date, 'yyyyMMdd') AS datum_geparsed,
        DAYOFWEEK(TO_DATE(date, 'yyyyMMdd')) AS dag_van_de_week,
        CASE DAYOFWEEK(TO_DATE(date, 'yyyyMMdd'))
            WHEN 1 THEN 'Zondag'
            WHEN 2 THEN 'Maandag'
            WHEN 3 THEN 'Dinsdag'
            WHEN 4 THEN 'Woensdag'
            WHEN 5 THEN 'Donderdag'
            WHEN 6 THEN 'Vrijdag'
            WHEN 7 THEN 'Zaterdag'
        END AS dag_naam,
        WEEKOFYEAR(TO_DATE(date, 'yyyyMMdd')) AS weeknummer,
        MONTH(TO_DATE(date, 'yyyyMMdd')) AS maand,
        YEAR(TO_DATE(date, 'yyyyMMdd')) AS jaar,
        COALESCE(DAYOFWEEK(TO_DATE(date, 'yyyyMMdd')) IN (1, 7), FALSE) AS is_weekend
    FROM bron
)

SELECT * FROM gecleand
