SELECT
    scenario_id,
    order_id,
    customer_id,
    order_vin,
    market,
    order_source_updated_at,
    order_loaded_at
FROM {{ ref('int_order_vehicle_coverage') }}
WHERE vehicle_found = FALSE
