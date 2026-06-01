
{{ config(materialized='view', schema='gold') }}

WITH CTE_Teams AS (
    SELECT
        CASE
            WHEN home_team_id < away_team_id THEN home_team_id
            ELSE away_team_id
        END team_a_id,
        CASE
            WHEN home_team_id < away_team_id THEN away_team_id
            ELSE home_team_id 
        END team_b_id,
        CASE
            WHEN home_team_id < away_team_id THEN score_full_time_home
            WHEN away_team_id < home_team_id THEN score_full_time_away
        END team_a_goals,
        CASE
            WHEN home_team_id > away_team_id THEN score_full_time_home
            WHEN away_team_id > home_team_id THEN score_full_time_away
        END team_b_goals,
        CASE
            WHEN home_team_id < away_team_id AND score_full_time_home > score_full_time_away THEN 'Team A Win'
            WHEN home_team_id < away_team_id AND score_full_time_home < score_full_time_away THEN 'Team B Win'
            WHEN home_team_id < away_team_id AND score_full_time_home = score_full_time_away THEN 'Draw'

            WHEN home_team_id > away_team_id AND score_full_time_home > score_full_time_away THEN 'Team B Win'
            WHEN home_team_id > away_team_id AND score_full_time_home < score_full_time_away THEN 'Team A Win'
            WHEN home_team_id > away_team_id AND score_full_time_home = score_full_time_away THEN 'Draw'
        END team_results
    FROM
        {{ref('fact_match')}}
),

CTE_TeamNames AS (
    SELECT
        team_a_id,
        ta.team_name team_a_name,
        team_a_goals,
        team_b_id,
        tb.team_name team_b_name,
        team_b_goals,
        team_results
    FROM
        CTE_Teams p
    LEFT JOIN
        {{ref('dim_team')}} ta
    ON
        p.team_a_id = ta.team_id
    LEFT JOIN
        {{ref('dim_team')}} tb
    ON
        p.team_b_id = tb.team_id
),

CTE_Aggs AS (
    SELECT
        team_a_name,
        team_b_name,
        COUNT(*) total_meetings,
        SUM(team_a_goals) team_a_goals,
        SUM(team_b_goals) team_b_goals,
        SUM(
            CASE
                WHEN team_results = 'Team A Win' THEN 1
                ELSE 0
            END
        ) team_a_wins,
        SUM(
            CASE
                WHEN team_results = 'Team B Win' THEN 1
                ELSE 0
            END
        ) team_b_wins,
        SUM(
            CASE
                WHEN team_results = 'Draw' THEN 1
                ELSE 0
            END
        ) draws
    FROM
        CTE_TeamNames
    GROUP BY
        team_a_name, team_b_name
)

SELECT
    team_a_name,
    team_b_name,
    total_meetings,
    team_a_goals,
    team_b_goals,
    team_a_wins,
    team_b_wins,
    draws
FROM
    CTE_Aggs