with orders as (
    select * from {{ ref('stg_orders') }}
),
vehicles as (
    select * from {{ ref('stg_vehicle') }}
),
vehicles_deduped as (
    select
        vehicle_id,
        vin,
        model_name,
        updated_at
    from vehicles
    qualify row_number() over (
        partition by vin
        order by updated_at desc, vehicle_id desc
    ) = 1
)

select
    orders.order_id,
    orders.vin,
    orders.market,
    orders.ordered_at,
    orders.order_value,
    vehicles_deduped.vehicle_id,
    vehicles_deduped.model_name
from orders
inner join vehicles_deduped
    on orders.vin = vehicles_deduped.vin
