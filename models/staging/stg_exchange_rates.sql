with source as (
    select * from {{ source('raw', 'RAW_EXCHANGE_RATES') }}
)

select
    currency_code,
    rate_to_usd,
    valid_on
from source
