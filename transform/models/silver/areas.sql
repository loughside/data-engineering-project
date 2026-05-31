
{{ config(materialized='table', schema='silver') }}
SELECT DISTINCT
  area_id,
  area_name
FROM 
  {{source('bronze', 'competitions')}}