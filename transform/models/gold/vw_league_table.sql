
{{config(materialized='view', schema='gold')}}

WITH CTE_RawTable AS (
  SELECT 
    c.name competition,
    matchday,
    team_name,
    COUNT(DISTINCT match_id) played,
    SUM(
      CASE
        WHEN goals_scored_full_time > goals_conceded_full_time THEN 1
        ELSE 0
      END
      ) wins,
    SUM(
      CASE
        WHEN goals_scored_full_time < goals_conceded_full_time THEN 1
        ELSE 0
      END
      ) losses,
    SUM(
      CASE
        WHEN goals_scored_full_time = goals_conceded_full_time THEN 1
        ELSE 0
      END
      ) draws,
    SUM(goals_scored_full_time) goals_for,
    SUM(goals_conceded_full_time) goals_against,
    SUM(goals_scored_full_time) - SUM(goals_conceded_full_time) goal_difference,
    SUM(points) points
  FROM 
    {{ref('fact_match_team')}} m
  LEFT JOIN
    {{ref('dim_team')}} t
  ON
    m.team_id = t.team_id
  LEFT JOIN
    {{ref('dim_competition')}} c
  ON
    m.competition_id = c.id
  GROUP BY
    c.name, matchday, team_name
),

CTE_RunningTotals AS (
  SELECT
    competition,
    matchday,
    team_name,
    SUM(played) OVER(PARTITION BY competition, team_name ORDER BY matchday ASC) P,
    SUM(wins) OVER(PARTITION BY competition, team_name ORDER BY matchday ASC) W,
    SUM(draws) OVER(PARTITION BY competition, team_name ORDER BY matchday ASC) D,
    SUM(losses) OVER(PARTITION BY competition, team_name ORDER BY matchday ASC) L,
    SUM(goals_for) OVER(PARTITION BY competition, team_name ORDER BY matchday ASC) GF,
    SUM(goals_against) OVER(PARTITION BY competition, team_name ORDER BY matchday ASC) GA,
    SUM(goals_for) OVER(PARTITION BY competition, team_name ORDER BY matchday ASC) - 
      SUM(goals_against) OVER(PARTITION BY competition, team_name ORDER BY matchday ASC) GD,
    SUM(points) OVER(PARTITION BY competition, team_name ORDER BY matchday ASC) Pts
  FROM
    CTE_RawTable
)

SELECT
  competition,
  matchday,
  ROW_NUMBER() OVER(PARTITION BY competition, matchday ORDER BY Pts DESC, GD DESC, GF DESC, GA ASC) position,
  team_name,
  P,
  W,
  D,
  L,
  GF,
  GA,
  GD,
  Pts
FROM
  CTE_RunningTotals