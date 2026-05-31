
{{ config(materialized='table', schema='gold') }}

SELECT
    season_id,
    season_start_date,
    season_end_date,
    season_label
FROM 
  {{ref('seasons')}}