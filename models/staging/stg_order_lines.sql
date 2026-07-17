with source as (
    select * from {{ source('raw', 'RAW_ORDER_LINES') }}
)

select
    order_id,
    line_number,
    line_value,
    market,
    order_date
from source
