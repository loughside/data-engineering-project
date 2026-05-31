
{{ config(materialized='table', schema='gold') }}

SELECT
  id match_id,
  competition_id,
  season_id,
  matchday,
  home_team_id team_id,
  1 is_home,
  score_half_time_home goals_scored_half_time,
  score_half_time_away goals_conceded_half_time,
  score_full_time_home goals_scored_full_time,
  score_full_time_away goals_conceded_full_time,
  CASE
    WHEN score_winner = 'AWAY_TEAM' THEN 0
    WHEN score_winner = 'HOME_TEAM' THEN 3
    WHEN score_winner = 'DRAW' THEN 1
    ELSE NULL
  END points,
  GETUTCDATE() AS _updated_at
FROM 
    {{ref('matches')}}
UNION ALL
SELECT
  id,
  competition_id,
  season_id,
  matchday,
  away_team_id,
  0 is_home,
  score_half_time_away,
  score_half_time_home,
  score_full_time_away,
  score_full_time_home,
  CASE
    WHEN score_winner = 'HOME_TEAM' THEN 0
    WHEN score_winner = 'AWAY_TEAM' THEN 3
    WHEN score_winner = 'DRAW' THEN 1
    ELSE NULL
  END points,
  GETUTCDATE() AS _updated_at
FROM 
    {{ref('matches')}}
  