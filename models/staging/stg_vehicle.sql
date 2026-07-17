with source as (
    select * from {{ source('raw', 'RAW_VEHICLE') }}
)

select
    vehicle_id,
    vin,
    model_name,
    updated_at
from source
