
import os
import requests
from dotenv import load_dotenv

class FootballDataClient:
    BASE_URL = "https://api.football-data.org/v4/"

    def __init__(self):
        load_dotenv()
        self.api_key = os.getenv("FOOTBALL_DATA_API_KEY")

    def get_competitions(self):
        try:
          url = self.BASE_URL + "competitions"
          headers = {"X-Auth-Token": self.api_key}
          response = requests.get(url,headers=headers)
        except requests.exceptions.RequestException as e:
            raise Exception(f"Network Error: {e}")

        if response.status_code != 200:
          raise Exception(f"API error {response.status_code}")

        return response.json()['competitions']