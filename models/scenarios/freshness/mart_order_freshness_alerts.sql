SELECT
    scenario_id,
    market,
    order_count,
    latest_source_updated_at,
    latest_loaded_at,
    DATEDIFF('hour', latest_loaded_at, TO_TIMESTAMP_NTZ('2026-07-15 00:00:00')) AS hours_since_loaded,
    DATEDIFF('hour', latest_loaded_at, TO_TIMESTAMP_NTZ('2026-07-15 00:00:00')) > 24 AS freshness_breached
FROM {{ ref('int_order_freshness') }}
