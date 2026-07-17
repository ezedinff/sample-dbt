select
    count(*) as order_count,
    max(loaded_at) as latest_loaded_at,
    datediff('hour', max(loaded_at), current_timestamp()) as stale_hours
from {{ ref('stg_orders') }}
where loaded_at is not null
