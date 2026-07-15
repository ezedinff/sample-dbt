SELECT *
FROM {{ ref('mart_order_freshness_alerts') }}
WHERE scenario_id = 'freshness_stale_orders'
  AND freshness_breached = TRUE
