WITH trips AS (
    SELECT * FROM {{ source('raw', 'raw_trips') }}
),

calendar_dates AS (
    SELECT * FROM {{ source('raw', 'raw_calendar_dates') }}
),

calendar AS (
    SELECT * FROM {{ ref('dim_calendar') }}
),

cleaned AS (
    SELECT
        {{ clean_empty_strings('t.trip_id') }} AS trip_id,
        {{ clean_empty_strings('t.route_id') }} AS route_id,
        {{ clean_empty_strings('t.service_id') }} AS service_id,
        {{ clean_empty_strings('t.trip_headsign') }} AS trip_headsign,
        {{ clean_empty_strings('t.direction_id') }} AS direction_id,
        cd.date,
        cd.exception_type,
        c.day_of_week,
        c.day_of_week_name,
        c.week_number,
        c.month,
        c.year,
        c.is_weekend
    FROM trips t
    LEFT JOIN calendar_dates cd ON t.service_id = cd.service_id
    LEFT JOIN calendar c ON cd.date = c.date
    WHERE cd.date IS NOT NULL
),

deduped AS (
    {{ deduplicate('cleaned', 'trip_id, date', 'trip_id') }}
)

SELECT * FROM deduped