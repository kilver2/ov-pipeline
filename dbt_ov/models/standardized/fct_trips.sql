WITH trips AS (
    SELECT * FROM {{ source('raw', 'raw_trips') }}
),

calendar_dates AS (
    SELECT * FROM {{ source('raw', 'raw_calendar_dates') }}
),

calendar AS (
    SELECT * FROM {{ ref('dim_calendar') }}
),

joined AS (
    SELECT
        t.trip_id,
        t.route_id,
        t.service_id,
        t.trip_headsign,
        t.direction_id,
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
)

SELECT * FROM joined