with events as (
    select * from {{ ref('stg_cart_events') }}
),
created as (
    select
        cart_id,
        session_id,
        user_id,
        market,
        currency_code,
        cart_value,
        min(event_timestamp) as cart_created_at
    from events
    where event_name = 'cart_created'
    group by 1, 2, 3, 4, 5, 6
),
abandoned as (
    select
        cart_id,
        min(event_timestamp) as cart_abandoned_at
    from events
    where event_name = 'cart_abandoned'
    group by 1
)

select
    created.cart_id,
    created.session_id,
    created.user_id,
    created.market,
    created.currency_code,
    created.cart_value,
    created.cart_created_at,
    abandoned.cart_abandoned_at,
    abandoned.cart_abandoned_at is not null as is_abandoned
from created
left join abandoned on created.cart_id = abandoned.cart_id
