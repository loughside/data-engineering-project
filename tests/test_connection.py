
import os
from dotenv import load_dotenv
import pyodbc

# load environment variables from .env file
load_dotenv()

SQL_DRIVER = os.getenv("SQL_DRIVER")
SQL_SERVER = os.getenv("SQL_SERVER") 
SQL_DATABASE = os.getenv("SQL_DATABASE")
SQL_USERNAME = os.getenv("SQL_USERNAME") 
SQL_PASSWORD = os.getenv("SQL_PASSWORD")

# Construct the connection string
cnxn_string = (
  f"Driver={{{SQL_DRIVER}}};"
  f"Server={SQL_SERVER};"
  f"Database={SQL_DATABASE};"
  f"UID={SQL_USERNAME};"
  f"PWD={SQL_PASSWORD};"
  "Encrypt=yes;TrustServerCertificate=no;"
)

print(cnxn_string)

cnxn = pyodbc.connect(cnxn_string)
cursor = cnxn.cursor()
cursor.execute("SELECT @@VERSION;")
row = cursor.fetchone()
print(row[0])
print("Connection successful!")