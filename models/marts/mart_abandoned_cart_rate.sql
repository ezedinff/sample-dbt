select
    market,
    currency_code,
    count(*) as created_carts,
    sum(case when is_abandoned then 1 else 0 end) as abandoned_carts,
    cast(sum(case when is_abandoned then 1 else 0 end) as number)
        / nullif(count(*), 0) as abandoned_cart_rate
from {{ ref('int_abandoned_cart') }}
group by 1, 2
