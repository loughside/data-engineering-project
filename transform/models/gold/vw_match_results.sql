
{{ config(materialized='view', schema='gold') }}

WITH CTE_HomeStats AS (
SELECT
    s.season_label,
    m.match_id,
    c.name competition,
    m.matchday,
    m.utc_date match_date,
    t.team_name home_team_name,
    m.goals_scored_full_time home_full_time_score,
    m.goals_scored_half_time home_half_time_score
FROM 
    {{ref('fact_match_team')}} m
LEFT JOIN
    {{ref('dim_competition')}} c
ON
    m.competition_id = c.id
LEFT JOIN
    {{ref('dim_team')}} t
ON
    m.team_id = t.team_id
LEFT JOIN
    {{ref('dim_season')}} s
ON
    m.season_id = s.season_id
WHERE
    m.is_home = 1),

CTE_AwayStats AS (
SELECT
    m.match_id,
    m.utc_date match_date,
    t.team_name away_team_name,
    m.goals_scored_full_time away_full_time_score,
    m.goals_scored_half_time away_half_time_score
FROM 
    {{ref('fact_match_team')}} m
LEFT JOIN
    {{ref('dim_team')}} t
ON
    m.team_id = t.team_id
WHERE
    m.is_home = 0),

CTE_RawData AS (
SELECT
    h.season_label,
    h.competition,
    h.matchday,
    h.match_date,
    h.home_team_name,
    h.home_full_time_score,
    h.home_half_time_score,

    a.away_team_name,
    a.away_full_time_score,
    a.away_half_time_score,

    CASE
        WHEN h.home_full_time_score > a.away_full_time_score THEN 'Home Team Win'
        WHEN h.home_full_time_score < a.away_full_time_score THEN 'Away Team Win'
        WHEN h.home_full_time_score = a.away_full_time_score THEN 'Draw'
    END result
FROM 
    CTE_HomeStats h
INNER JOIN
    CTE_AwayStats a
ON
    h.match_id = a.match_id)

SELECT
    season_label season,
    competition,
    matchday,
    FORMAT(match_date, 'ddd, d MMM yyyy') match_date,
    home_team_name + ' vs. ' + away_team_name [match],
    home_team_name + ' ' + CAST(home_half_time_score AS NVARCHAR) + ' - ' + CAST(away_half_time_score AS NVARCHAR)+ ' ' + away_team_name half_time_score,
    home_team_name + ' ' + CAST(home_full_time_score AS NVARCHAR) + ' - ' + CAST(away_full_time_score AS NVARCHAR) + ' ' + away_team_name full_time_score,
    result
FROM
    CTE_RawData