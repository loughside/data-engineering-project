
{{ config(materialized='table', schema='gold') }}

SELECT 
  id, 
  competition_id, 
  season_id, 
  matchday, 
  home_team_id, 
  away_team_id, 
  utc_date, 
  status, 
  stage, 
  [group], 
  score_winner, 
  score_duration, 
  score_full_time_home, 
  score_full_time_away, 
  score_half_time_home, 
  score_half_time_away,
  GETUTCDATE() AS _updated_at
FROM 
    {{ref('matches')}}
