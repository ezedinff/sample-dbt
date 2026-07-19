select
    order_id,
    line_number,
    market,
    order_date,
    line_value as order_revenue
from {{ ref('stg_order_lines') }}
