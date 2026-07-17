-- INTENTIONAL BREAK (join_explosion):
-- Joins vehicles on vin without deduplicating the right side.
-- When RAW_VEHICLE has duplicate vins, this fans out order rows.
-- Expected fix: dedupe vehicle (qualify row_number) before join.

with orders as (
    select * from {{ ref('stg_orders') }}
),
vehicles as (
    select
        vehicle_id,
        vin,
        model_name
    from {{ ref('stg_vehicle') }}
    qualify row_number() over (
        partition by vin
        order by vehicle_id
    ) = 1
)

select
    orders.order_id,
    orders.vin,
    orders.market,
    orders.ordered_at,
    orders.order_value,
    vehicles.vehicle_id,
    vehicles.model_name
from orders
inner join vehicles
    on orders.vin = vehicles.vin