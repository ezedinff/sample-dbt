select
    o.order_id,
    o.currency_code,
    coalesce(o.order_value, o.amount) as amount,
    coalesce(o.order_date, try_to_date(o.ordered_at)) as order_date,
    r.rate_to_usd,
    coalesce(o.order_value, o.amount) * r.rate_to_usd as amount_usd
from {{ ref('stg_orders') }} o
left join {{ ref('stg_exchange_rates') }} r
    on o.currency_code = r.currency_code
   and coalesce(o.order_date, try_to_date(o.ordered_at)) = r.valid_on
