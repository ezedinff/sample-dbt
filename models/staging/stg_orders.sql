with source as (
    select * from {{ source('raw', 'RAW_ORDERS') }}
)

select
    order_id,
    vin,
    market,
    ordered_at,
    order_value,
    loaded_at,
    currency_code,
    amount,
    order_date
from source
