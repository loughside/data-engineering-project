
{{ config(materialized='view', schema='gold') }}

WITH CTE_HomeOrAway AS (
    SELECT
        m.match_id,
        t.team_name,
        m.team_id,
        m.utc_date match_date,
        c.name competition,
        m.matchday,
        CASE
            WHEN is_home = 1 THEN 'Home'
            WHEN is_home = 0 THEN 'Away'
        END home_or_away,
        m.goals_scored_full_time goals_scored,
        m.goals_conceded_full_time goals_conceded,
        CASE
            WHEN m.goals_scored_full_time > m.goals_conceded_full_time THEN 'Win'
            WHEN m.goals_scored_full_time < m.goals_conceded_full_time THEN 'Lose'
            WHEN m.goals_scored_full_time = m.goals_conceded_full_time THEN 'Draw'
        END result,
        m.points
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
),

CTE_SelfJoin AS (
    SELECT
        c1.team_name,
        c1.match_date,
        c1.competition,
        c1.matchday,
        c1.home_or_away,
        c2.team_name opponent_name,
        c1.goals_scored,
        c1.goals_conceded,
        c1.result,
        c1.points
    FROM
        CTE_HomeOrAway c1
    INNER JOIN
        CTE_HomeOrAway c2
    ON 
        c1.match_id = c2.match_id
    AND
        c1.team_id != c2.team_id
),

CTE_Last5Ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY team_name ORDER BY match_date DESC) last_5_rank
    FROM
        CTE_SelfJoin
)

SELECT
    *
FROM
    CTE_Last5Ranking
