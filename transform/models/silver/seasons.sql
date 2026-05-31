
{{ config(materialized='table', schema='silver') }}

SELECT DISTINCT
    season_id,
    season_start_date,
    season_end_date,
    DATENAME(YEAR, season_start_date) + '/' + RIGHT(DATENAME(YEAR, season_end_date), 2) season_label
FROM 
  {{source('bronze', 'matches')}}