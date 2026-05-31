
{{ config(materialized='table', schema='silver') }}

SELECT
  home_team_id team_id,
  home_team_name team_name,
  home_team_tla team_tla, 
  home_team_short_name team_short_name, 
  home_team_crest team_crest
FROM 
    {{source('bronze', 'matches')}}
UNION
SELECT
  away_team_id,
  away_team_name,
  away_team_tla, 
  away_team_short_name, 
  away_team_crest
FROM 
    {{source('bronze', 'matches')}}
  