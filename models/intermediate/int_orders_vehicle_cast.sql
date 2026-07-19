with orders as (
    select * from {{ ref('stg_orders') }}
),
vehicles as (
    select * from {{ ref('stg_vehicle') }}
)

select
    orders.order_id,
    orders.vin as order_vin,
    vehicles.vin as vehicle_vin,
    vehicles.vehicle_id,
    vehicles.model_name
from orders
left join vehicles
    on orders.vin = vehicles.vin
