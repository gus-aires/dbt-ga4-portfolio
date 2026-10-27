with source as (
select *
from {{source('ga4','events')}}
where _TABLE_SUFFIX between '20201101' and '20201107'
),
renamed as (
    select
  event_name,
  user_pseudo_id,
  geo.country,
  device.category as device_category,
  traffic_source.source as traffic_source,
  traffic_source.medium as traffic_medium,
  traffic_source.name as traffic_campaign, 
  parse_date('%Y%m%d', event_date) as event_date,
  timestamp_micros(event_timestamp) as event_at,
  ecommerce.transaction_id as transaction_id,
  ecommerce.purchase_revenue_in_usd as purchase_revenue_usd
from source
)
select * from renamed