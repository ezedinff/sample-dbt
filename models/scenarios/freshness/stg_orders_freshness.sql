SELECT
    scenario_id,
    record_source,
    ingest_batch_id,
    order_id,
    customer_id,
    vin,
    market,
    order_status,
    order_amount,
    source_updated_at,
    loaded_at
FROM {{ source('raw', 'orders') }}
WHERE scenario_id IN (
    'baseline',
    'freshness_stale_orders',
    'freshness_repo_local_regression'
)
