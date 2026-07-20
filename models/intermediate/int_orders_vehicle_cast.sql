with orders as (
    select * from {{ ref('stg_orders') }}
),
vehicles as (
    select vehicle_id, vin, model_name, updated_at
    from {{ ref('stg_vehicle') }}
    qualify row_number() over (
        partition by vin
        order by updated_at desc, vehicle_id desc
    ) = 1
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
