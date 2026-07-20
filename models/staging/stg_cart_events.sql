with source as (
    select * from {{ source('raw', 'RAW_EVENTS_CART') }}
)

select
    session_id,
    cart_id,
    user_id,
    event_timestamp,
    event_name,
    currency_code,
    cart_value,
    market
from source
