
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'matches' AND schema_id = SCHEMA_ID('bronze'))
  EXEC('
  CREATE TABLE bronze.matches (
    id INT,
    competition_id INT,
    season_id INT,
    season_start_date DATE,
    season_end_date DATE,
    matchday INT,
    home_team_id INT,
    home_team_name NVARCHAR(100),
    home_team_short_name NVARCHAR(100),
    home_team_tla NVARCHAR(10),
    home_team_crest NVARCHAR(255),
    away_team_id INT,
    away_team_name NVARCHAR(100),
    away_team_short_name NVARCHAR(100),
    away_team_tla NVARCHAR(10),
    away_team_crest NVARCHAR(255),
    utc_date DATETIME2,
    status NVARCHAR(50),
    stage NVARCHAR(50),
    [group] NVARCHAR(50),
    score_winner NVARCHAR(50),
    score_duration NVARCHAR(50),
    score_full_time_home INT,
    score_full_time_away INT,
    score_half_time_home INT,
    score_half_time_away INT,
    _ingested_at DATETIME2,
    _last_updated DATETIME2)
  ')