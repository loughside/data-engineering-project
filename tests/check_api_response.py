
import requests as re
import os
from dotenv import load_dotenv
load_dotenv()

api_url = 'https://api.football-data.org/v4/competitions/' 
api_key = os.getenv("FOOTBALL_DATA_API_KEY")

headers = {
  "Authorization": f"X-Auth-Token {api_key}",
  "Content-Type": "application/json",
  }


response = re.get(
  api_url,
  headers=headers
  )

competitions = response.json()['competitions']

print(competitions[0])