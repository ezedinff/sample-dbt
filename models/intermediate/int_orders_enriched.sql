with orders as (
    select * from {{ ref('stg_orders') }}
),
vehicles as (
    select * from {{ ref('stg_vehicle') }}
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
