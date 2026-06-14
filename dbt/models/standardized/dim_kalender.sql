-- TODO: toevoegen TO_DATE CTE voor Spark SQL
-- Inladen raw calendar en ook feestdagen
WITH bron AS (
    SELECT * FROM {{ source('raw', 'raw_calendar_dates') }}
),

feestdagen AS (
    SELECT * FROM {{ ref('dim_feestdagen') }}
),

-- Casting, vernederlandsing en toevoegen van extra kolommen
gecleand AS (
    SELECT DISTINCT
        b.date AS datum,
        f.feestdag_naam,
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
        CASE MONTH(TO_DATE(b.date, 'yyyyMMdd'))
            WHEN 1 THEN 'Januari'
            WHEN 2 THEN 'Februari'
            WHEN 3 THEN 'Maart'
            WHEN 4 THEN 'April'
            WHEN 5 THEN 'Mei'
            WHEN 6 THEN 'Juni'
            WHEN 7 THEN 'Juli'
            WHEN 8 THEN 'Augustus'
            WHEN 9 THEN 'September'
            WHEN 10 THEN 'Oktober'
            WHEN 11 THEN 'November'
            WHEN 12 THEN 'December'
        END AS maand_naam,
        YEAR(TO_DATE(b.date, 'yyyyMMdd')) AS jaar,
        COALESCE(DAYOFWEEK(TO_DATE(b.date, 'yyyyMMdd')) IN (1, 7), FALSE) AS is_weekend,
        COALESCE(f.datum IS NOT NULL, FALSE) AS is_feestdag
    FROM bron AS b
    LEFT JOIN feestdagen AS f ON TO_DATE(b.date, 'yyyyMMdd') = TO_DATE(f.datum, 'yyyy-MM-dd')
)

SELECT * FROM gecleand
