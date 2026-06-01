{{ config(materialized='view', schema='gold') }}

WITH CTE_SeasonStats AS (
    SELECT 
        t.team_id,
        t.team_name,
        se.season_label,
        co.name competition,
        COUNT(DISTINCT m.match_id) games_played,
        SUM(
            CASE
                WHEN m.goals_scored_full_time > m.goals_conceded_full_time THEN 1
                ELSE 0
            END) games_won,
        SUM(
            CASE
                WHEN m.goals_scored_full_time < m.goals_conceded_full_time THEN 1
                ELSE 0
            END) games_lost,
        SUM(
            CASE
                WHEN m.goals_scored_full_time = m.goals_conceded_full_time THEN 1
                ELSE 0
            END) games_drawn,
        SUM(goals_scored_full_time) goals_scored,
        SUM(goals_conceded_full_time) goals_conceded,
        SUM(goals_scored_full_time) - SUM(goals_conceded_full_time) goal_difference,
        SUM(
            CASE
                WHEN m.goals_conceded_full_time = 0 THEN 1
                ELSE 0
            END) clean_sheets,
        SUM(m.points) total_points,
        CAST(SUM(m.points) AS NUMERIC) / COUNT(DISTINCT m.match_id) points_per_game
    FROM   
        {{ ref('fact_match_team') }} m
    INNER JOIN
        {{ ref('dim_team') }} t
    ON
        m.team_id = t.team_id
    INNER JOIN
        {{ ref('dim_season') }} se
    ON
        m.season_id = se.season_id
    INNER JOIN
        {{ ref('dim_competition') }} co
    ON
        m.competition_id = co.id
    GROUP BY
        t.team_id, t.team_name, se.season_label, co.name),

CTE_HomeStats AS (
    SELECT 
        t.team_id,
        t.team_name,
        se.season_label,
        co.name competition,
        COUNT(DISTINCT m.match_id) home_games_played,
        SUM(
            CASE
                WHEN m.goals_scored_full_time > m.goals_conceded_full_time THEN 1
                ELSE 0
            END) home_games_won,
        SUM(
            CASE
                WHEN m.goals_scored_full_time < m.goals_conceded_full_time THEN 1
                ELSE 0
            END) home_games_lost,
        SUM(
            CASE
                WHEN m.goals_scored_full_time = m.goals_conceded_full_time THEN 1
                ELSE 0
            END) home_games_drawn,
        SUM(goals_scored_full_time) home_goals_scored,
        SUM(goals_conceded_full_time) home_goals_conceded,
        SUM(goals_scored_full_time) - SUM(goals_conceded_full_time) home_goal_difference,
        SUM(
            CASE
                WHEN m.goals_conceded_full_time = 0 THEN 1
                ELSE 0
            END) home_clean_sheets,
        SUM(m.points) home_total_points,
        CAST(SUM(m.points) AS NUMERIC) / COUNT(DISTINCT m.match_id) home_points_per_game
    FROM   
        {{ ref('fact_match_team') }} m
    INNER JOIN
        {{ ref('dim_team') }} t
    ON
        m.team_id = t.team_id
    AND 
        m.is_home = 1
    INNER JOIN
        {{ ref('dim_season') }} se
    ON
        m.season_id = se.season_id
    INNER JOIN
        {{ ref('dim_competition') }} co
    ON
        m.competition_id = co.id
    GROUP BY
        t.team_id, t.team_name, se.season_label, co.name
),

CTE_AwayStats AS (
    SELECT 
        t.team_id,
        t.team_name,
        se.season_label,
        co.name competition,
        COUNT(DISTINCT m.match_id) away_games_played,
        SUM(
            CASE
                WHEN m.goals_scored_full_time > m.goals_conceded_full_time THEN 1
                ELSE 0
            END) away_games_won,
        SUM(
            CASE
                WHEN m.goals_scored_full_time < m.goals_conceded_full_time THEN 1
                ELSE 0
            END) away_games_lost,
        SUM(
            CASE
                WHEN m.goals_scored_full_time = m.goals_conceded_full_time THEN 1
                ELSE 0
            END) away_games_drawn,
        SUM(goals_scored_full_time) away_goals_scored,
        SUM(goals_conceded_full_time) away_goals_conceded,
        SUM(goals_scored_full_time) - SUM(goals_conceded_full_time) away_goal_difference,
        SUM(
            CASE
                WHEN m.goals_conceded_full_time = 0 THEN 1
                ELSE 0
            END) away_clean_sheets,
        SUM(m.points) away_total_points,
        CAST(SUM(m.points) AS NUMERIC) / COUNT(DISTINCT m.match_id) away_points_per_game
    FROM   
        {{ ref('fact_match_team') }} m
    INNER JOIN
        {{ ref('dim_team') }} t
    ON
        m.team_id = t.team_id
    AND 
        m.is_home = 0
    INNER JOIN
        {{ ref('dim_season') }} se
    ON
        m.season_id = se.season_id
    INNER JOIN
        {{ ref('dim_competition') }} co
    ON
        m.competition_id = co.id
    GROUP BY
        t.team_id, t.team_name, se.season_label, co.name
)

SELECT
    s.team_id,
    s.team_name,
    s.season_label,
    s.competition,
    s.games_played,
    s.games_won,
    s.games_lost,
    s.games_drawn,
    s.goals_scored,
    s.goals_conceded,
    s.goal_difference,
    s.clean_sheets,
    s.total_points,
    s.points_per_game,
    h.home_games_played,
    h.home_games_won,
    h.home_games_lost,
    h.home_games_drawn,
    h.home_goals_scored,
    h.home_goals_conceded,
    h.home_goal_difference,
    h.home_clean_sheets,
    h.home_total_points,
    h.home_points_per_game,
    a.away_games_played,
    a.away_games_won,
    a.away_games_lost,
    a.away_games_drawn,
    a.away_goals_scored,
    a.away_goals_conceded,
    a.away_goal_difference,
    a.away_clean_sheets,
    a.away_total_points,
    a.away_points_per_game
FROM
    CTE_SeasonStats s
LEFT JOIN
    CTE_HomeStats h
ON
    s.team_id = h.team_id
AND
    s.competition = h.competition
AND
    s.season_label = h.season_label
LEFT JOIN
    CTE_AwayStats a
ON
    s.team_id = a.team_id
AND
    s.competition = a.competition
AND
    s.season_label = a.season_label