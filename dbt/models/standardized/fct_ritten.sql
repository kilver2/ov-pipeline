-- TODO toevoegen van PK en incremental loads op PK met is_incremental in config yaml
-- Inladen ritten raw
WITH ritten AS (
    SELECT * FROM {{ source('raw', 'raw_trips') }}
),

-- Inladen raw kalender en ook dim_kalender. Vanwege raw calender(service_id), die niet meer beschikbaar is in dim_kalendar. Service_id link je uiteindelijk met trips
kalender_datums AS (
    SELECT * FROM {{ source('raw', 'raw_calendar_dates') }}
),

kalender AS (
    SELECT * FROM {{ ref('dim_kalender') }}
),

-- Casting, vernederlandsing, toevoegen van extra kolommen en ook filteren op datum. Soms is die leeg namelijk
gecleand AS (
    SELECT
        {{ clean_empty_strings('r.trip_id') }} AS rit_id,
        {{ clean_empty_strings('r.route_id') }} AS route_id,
        {{ clean_empty_strings('r.service_id') }} AS dienst_id,
        {{ clean_empty_strings('r.trip_headsign') }} AS bestemming,
        {{ clean_empty_strings('r.direction_id') }} AS richting_id,
        kd.date AS datum,
        CASE kd.exception_type
            WHEN '1' THEN 'Toegevoegd'
            WHEN '2' THEN 'Verwijderd'
            ELSE 'Onbekend'
        END AS uitzondering_type,
        k.dag_van_de_week,
        k.dag_naam,
        k.weeknummer,
        k.maand,
        k.jaar,
        k.is_weekend
    FROM ritten AS r
    LEFT JOIN kalender_datums AS kd ON r.service_id = kd.service_id
    LEFT JOIN kalender AS k ON kd.date = k.datum
    WHERE kd.date IS NOT NULL
),

-- Deduplication op rit en datum, zou ook met PK kunnen
ontdubbeld AS (
    {{ deduplicate('gecleand', 'rit_id, datum', 'rit_id') }}
)

SELECT * FROM ontdubbeld
