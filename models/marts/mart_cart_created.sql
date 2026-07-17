-- INTENTIONAL BREAK (filter_overreach):
-- Hard-filters market = 'DE', silently dropping SE volume that exists in RAW.
-- Reads source directly so this break is independent of the cart field-rename bug.
-- Expected fix: remove or parameterize the market filter.

select
    market,
    count(*) as created_carts
from {{ source('raw', 'RAW_EVENTS_CART') }}
where event_name = 'cart_created'
  and market = 'DE'
group by 1
