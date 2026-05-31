
import requests as re
import os
from dotenv import load_dotenv
load_dotenv()

api_url = 'https://api.football-data.org/v4/competitions/PL/matches' 
api_key = os.getenv("FOOTBALL_DATA_API_KEY")

headers = {
  "X-Auth-Token": api_key,
  }

response = re.get(
  api_url,
  headers=headers
  )

matches = response.json()['matches']

print(matches[0])