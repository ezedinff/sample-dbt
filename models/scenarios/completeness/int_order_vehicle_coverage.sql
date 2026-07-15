WITH orders AS (
    SELECT *
    FROM {{ source('raw', 'orders') }}
    WHERE scenario_id IN ('baseline', 'completeness_missing_100_vins')
),
vehicles AS (
    SELECT *
    FROM {{ source('raw', 'vehicle') }}
    WHERE scenario_id IN ('baseline', 'completeness_missing_100_vins')
)

SELECT
    orders.scenario_id,
    orders.order_id,
    orders.customer_id,
    orders.vin AS order_vin,
    vehicles.vin AS vehicle_vin,
    vehicles.vehicle_id,
    orders.market,
    orders.source_updated_at AS order_source_updated_at,
    vehicles.source_updated_at AS vehicle_source_updated_at,
    orders.loaded_at AS order_loaded_at,
    vehicles.loaded_at AS vehicle_loaded_at,
    vehicles.vin IS NOT NULL AS vehicle_found
FROM orders
LEFT JOIN vehicles
    ON orders.vin = vehicles.vin
    AND orders.scenario_id = vehicles.scenario_id
