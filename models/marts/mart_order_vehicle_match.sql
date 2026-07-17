select
    (select count(distinct vin) from {{ ref('stg_orders') }}) as order_vins,
    (select count(distinct vin) from {{ ref('stg_vehicle') }}) as vehicle_vins,
    (
        select count(*)
        from {{ ref('stg_orders') }} o
        left join {{ ref('stg_vehicle') }} v on o.vin = v.vin
        where v.vin is null
    ) as missing_vehicle_vins
