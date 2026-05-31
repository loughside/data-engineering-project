
{{ config(materialized='table', schema='gold') }}

SELECT
  team_id,
  team_name,
  team_tla, 
  team_short_name, 
  team_crest
FROM 
    {{ref('teams')}}
