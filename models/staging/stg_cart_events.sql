-- INTENTIONAL BREAK (cart_rename_broken):
-- Upstream source column is event_name. This staging model still selects event_type.
-- Expected bounded fix: replace event_type -> event_name.

with source as (
    select * from {{ source('raw', 'RAW_EVENTS_CART') }}
)

select
    session_id,
    cart_id,
    user_id,
    event_timestamp,
    event_type,
    currency_code,
    cart_value,
    market
from source
