with orders as (
    select * from {{ ref('stg_orders') }}
),
vehicles as (
    select * from {{ ref('stg_vehicle') }}
),
deduped_vehicles as (
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
    deduped_vehicles.vehicle_id,
    deduped_vehicles.model_name
from orders
inner join deduped_vehicles
    on orders.vin = deduped_vehicles.vin
