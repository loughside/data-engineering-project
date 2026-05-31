
from ingestion.src.clients.football_data_client import FootballDataClient
from ingestion.src.loaders.sql_loader import SqlLoader

# Define list of Big 5 Leagues
COMPETITIONS = ['PL', 'BL1', 'SA', 'FL1', 'PD']

def run_matches_pipeline():
  c = FootballDataClient()
  s = SqlLoader()
  for code in COMPETITIONS:  
    result = c.get_matches(code, 2024)            
    print(f"Fetched {len(result)} matches for {code}")
    s.load_matches(result)

if __name__ == "__main__":
  run_matches_pipeline()