
{{ config(materialized='table', schema='gold') }}

SELECT
  id,
  name,
  code,
  type,
  emblem,
  area_id,
  GETUTCDATE() AS _updated_at
FROM 
    {{ref('competitions')}}
