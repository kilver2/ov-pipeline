WITH fct AS (
    SELECT * FROM {{ ref('fct_trips') }}
)

SELECT
    day_of_week,
    day_of_week_name,
    is_weekend,
    COUNT(trip_id) AS total_trips
FROM fct
GROUP BY day_of_week, day_of_week_name, is_weekend
ORDER BY day_of_week