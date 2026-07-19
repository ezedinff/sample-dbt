select
    market,
    count(*) as created_carts
from {{ source('raw', 'RAW_EVENTS_CART') }}
where event_name = 'cart_created'
  and market = 'DE'
group by 1
