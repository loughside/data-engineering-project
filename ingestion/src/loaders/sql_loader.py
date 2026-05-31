
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
                target.area_name = source.area_name,
                target._ingested_at = source._ingested_at
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