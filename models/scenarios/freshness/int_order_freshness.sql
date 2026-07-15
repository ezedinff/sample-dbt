SELECT
    scenario_id,
    market,
    COUNT(*) AS order_count,
    MAX(source_updated_at) AS latest_source_updated_at,
    MAX(loaded_at) AS latest_loaded_at
FROM {{ source('raw', 'orders') }}
WHERE scenario_id IN ('baseline', 'freshness_stale_orders')
GROUP BY 1, 2
