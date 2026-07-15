SELECT
    scenario_id,
    market,
    COUNT(*) AS order_count,
    CAST(NULL AS TIMESTAMP_NTZ) AS latest_source_updated_at,
    MAX(loaded_at) AS latest_loaded_at
FROM {{ ref('stg_orders_freshness') }}
WHERE scenario_id IN (
    'baseline',
    'freshness_stale_orders',
    'freshness_repo_local_regression'
)
GROUP BY 1, 2
