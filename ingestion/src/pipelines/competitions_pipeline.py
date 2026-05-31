
from ingestion.src.clients.football_data_client import FootballDataClient
from ingestion.src.loaders.sql_loader import SqlLoader

def run_competitions_pipeline():
  c = FootballDataClient()            # this runs __init__
  result = c.get_competitions()       # now you can call methods on the instance
  
  s = SqlLoader()
  s.load_competitions(result)

if __name__ == "__main__":
  run_competitions_pipeline()