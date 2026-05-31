
import os
from dotenv import load_dotenv
import pyodbc
import datetime as dt

# load environment variables from .env file
load_dotenv()

SQL_DRIVER = os.getenv("SQL_DRIVER")
SQL_SERVER = os.getenv("SQL_SERVER") 
SQL_DATABASE = os.getenv("SQL_DATABASE")
SQL_USERNAME = os.getenv("SQL_USERNAME") 
SQL_PASSWORD = os.getenv("SQL_PASSWORD")

# Define the SqlLoader class
class SqlLoader:
    def __init__(self):
        # Construct the connection string
        cnxn_string = (
          f"Driver={{{SQL_DRIVER}}};"
          f"Server={SQL_SERVER};"
          f"Database={SQL_DATABASE};"
          f"UID={SQL_USERNAME};"
          f"PWD={SQL_PASSWORD};"
          "Encrypt=yes;TrustServerCertificate=no;"
        )
        # Connect to the database
        self.cnxn = pyodbc.connect(cnxn_string)
          
    def load_competitions(self, competitions):
        # Create a cursor
        cursor = self.cnxn.cursor()
        _ingested_at = dt.datetime.now(dt.timezone.utc)

        # Write the MERGE T-SQL query
        merge_sql = (
            """
            MERGE INTO 
              bronze.competitions AS target
            USING 
              (VALUES (?, ?, ?, ?, ?, ?, ?, ?)) AS source (id, name, code, type, emblem, area_id, area_name, _ingested_at)
            ON 
              target.id = source.id
            WHEN MATCHED THEN UPDATE 
              SET 
                target.name = source.name,
                target.code = source.code,
                target.type = source.type,
                target.emblem = source.emblem,
                target.area_id = source.area_id,
                target.area_name = source.area_name
            WHEN NOT MATCHED THEN
                INSERT (id, name, code, type, emblem, area_id, area_name, _ingested_at)
                  VALUES (
                    source.id,
                    source.name,
                    source.code,
                    source.type,
                    source.emblem,
                    source.area_id,
                    source.area_name,
                    source._ingested_at);
            """
        )

        for comp in competitions:
          values = (
              comp["id"],
              comp["name"],
              comp["code"],
              comp["type"],
              comp["emblem"],
              comp["area"]["id"],
              comp["area"]["name"],
              _ingested_at
          )
          cursor.execute(merge_sql, values)

        self.cnxn.commit()

    def load_matches(self, matches):
        # Create a cursor
        cursor = self.cnxn.cursor()
        _ingested_at = dt.datetime.now(dt.timezone.utc)

        # Write the MERGE T-SQL query
        merge_sql = (
            """
            MERGE INTO 
              bronze.matches AS target
            USING 
              (VALUES (
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?, ?, ?, ?)) AS 
              source (
                id,
                competition_id,
                season_id,
                season_start_date,
                season_end_date,
                matchday,
                home_team_id,
                home_team_name,
                home_team_short_name,
                home_team_tla,
                home_team_crest,
                away_team_id,
                away_team_name,
                away_team_short_name,
                away_team_tla,
                away_team_crest,
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
                _ingested_at,
                _last_updated)
            ON 
              target.id = source.id
            WHEN MATCHED THEN UPDATE 
              SET 
                target.competition_id = source.competition_id,
                target.season_id = source.season_id,
                target.season_start_date = source.season_start_date,
                target.season_end_date = source.season_end_date,
                target.matchday = source.matchday,
                target.home_team_id = source.home_team_id,
                target.home_team_name = source.home_team_name,
                target.home_team_short_name = source.home_team_short_name,
                target.home_team_tla = source.home_team_tla,
                target.home_team_crest = source.home_team_crest,
                target.away_team_id = source.away_team_id,
                target.away_team_name = source.away_team_name,
                target.away_team_short_name = source.away_team_short_name,
                target.away_team_tla = source.away_team_tla,
                target.away_team_crest = source.away_team_crest,
                target.utc_date = source.utc_date,
                target.status = source.status,
                target.stage = source.stage,
                target.[group] = source.[group],
                target.score_winner = source.score_winner,
                target.score_duration = source.score_duration,
                target.score_full_time_home = source.score_full_time_home,
                target.score_full_time_away = source.score_full_time_away,
                target.score_half_time_home = source.score_half_time_home,
                target.score_half_time_away = source.score_half_time_away,
                target._last_updated = source._last_updated
            WHEN NOT MATCHED THEN
                INSERT (
                  id,
                  competition_id,
                  season_id,
                  season_start_date,
                  season_end_date,
                  matchday,
                  home_team_id,
                  home_team_name,
                  home_team_short_name,
                  home_team_tla,
                  home_team_crest,
                  away_team_id,
                  away_team_name,
                  away_team_short_name,
                  away_team_tla,
                  away_team_crest,
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
                  _ingested_at,
                  _last_updated)
                VALUES (
                  source.id,
                  source.competition_id,
                  source.season_id,
                  source.season_start_date,
                  source.season_end_date,
                  source.matchday,
                  source.home_team_id,
                  source.home_team_name,
                  source.home_team_short_name,
                  source.home_team_tla,
                  source.home_team_crest,
                  source.away_team_id,
                  source.away_team_name,
                  source.away_team_short_name,
                  source.away_team_tla,
                  source.away_team_crest,
                  source.utc_date,
                  source.status,
                  source.stage,
                  source.[group],
                  source.score_winner,
                  source.score_duration,
                  source.score_full_time_home,
                  source.score_full_time_away,
                  source.score_half_time_home,
                  source.score_half_time_away,
                  source._ingested_at,
                  source._last_updated);
            """
        )

        for match in matches:
          values = (
                match["id"],
                match["competition"]["id"],
                match["season"]["id"],
                match["season"]["startDate"],
                match["season"]["endDate"],
                match["matchday"],
                match["homeTeam"]["id"],
                match["homeTeam"]["name"],
                match["homeTeam"]["shortName"],
                match["homeTeam"]["tla"],
                match["homeTeam"]["crest"],
                match["awayTeam"]["id"],
                match["awayTeam"]["name"],
                match["awayTeam"]["shortName"],
                match["awayTeam"]["tla"],
                match["awayTeam"]["crest"],
                match["utcDate"],
                match["status"],
                match["stage"],
                match["group"],
                match["score"]["winner"],
                match["score"]["duration"],
                match["score"]["fullTime"]["home"],
                match["score"]["fullTime"]["away"],
                match["score"]["halfTime"]["home"],
                match["score"]["halfTime"]["away"],
                _ingested_at,
                match["lastUpdated"]
          )
          cursor.execute(merge_sql, values)

        self.cnxn.commit()
    
      