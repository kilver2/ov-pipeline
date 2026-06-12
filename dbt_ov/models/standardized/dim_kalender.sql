WITH bron AS (
    SELECT * FROM {{ source('raw', 'raw_calendar_dates') }}
),

feestdagen AS (
    SELECT * FROM {{ ref('dim_feestdagen') }}
),

gecleand AS (
    SELECT DISTINCT
        b.date AS datum,
        TO_DATE(b.date, 'yyyyMMdd') AS datum_geparsed,
        DAYOFWEEK(TO_DATE(b.date, 'yyyyMMdd')) AS dag_van_de_week,
        CASE DAYOFWEEK(TO_DATE(b.date, 'yyyyMMdd'))
            WHEN 1 THEN 'Zondag'
            WHEN 2 THEN 'Maandag'
            WHEN 3 THEN 'Dinsdag'
            WHEN 4 THEN 'Woensdag'
            WHEN 5 THEN 'Donderdag'
            WHEN 6 THEN 'Vrijdag'
            WHEN 7 THEN 'Zaterdag'
        END AS dag_naam,
        WEEKOFYEAR(TO_DATE(b.date, 'yyyyMMdd')) AS weeknummer,
        MONTH(TO_DATE(b.date, 'yyyyMMdd')) AS maand,
        YEAR(TO_DATE(b.date, 'yyyyMMdd')) AS jaar,
        COALESCE(DAYOFWEEK(TO_DATE(b.date, 'yyyyMMdd')) IN (1, 7), FALSE) AS is_weekend,
        CASE WHEN f.datum IS NOT NULL THEN TRUE ELSE FALSE END AS is_feestdag,
        f.feestdag_naam
    FROM bron b
    LEFT JOIN feestdagen f ON TO_DATE(b.date, 'yyyyMMdd') = TO_DATE(f.datum, 'yyyy-MM-dd')
)

SELECT * FROM gecleand