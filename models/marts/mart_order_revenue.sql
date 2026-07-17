-- INTENTIONAL BREAK (wrong_grain_mart):
-- Exposes line-level rows as order_revenue without aggregating to order grain.
-- Expected fix: group by order_id and sum(line_value).

select
    order_id,
    line_number,
    market,
    order_date,
    line_value as order_revenue
from {{ ref('stg_order_lines') }}
