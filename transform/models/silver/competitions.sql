
{{ config(materialized='table', schema='silver') }}

SELECT
  id,
  name,
  code,
  type,
  emblem,
  area_id,
  GETUTCDATE() AS _updated_at
FROM 
  {{source('bronze', 'competitions')}}