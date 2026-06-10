from databricks import sql
from dotenv import load_dotenv
import os

load_dotenv()

HOST = os.getenv("DATABRICKS_HOST")
TOKEN = os.getenv("DATABRICKS_TOKEN")
HTTP_PATH = os.getenv("DATABRICKS_HTTP_PATH")

print(f"HOST: {HOST}")
print(f"HTTP_PATH: {HTTP_PATH}")
print(f"TOKEN: {TOKEN[:10]}...")

with sql.connect(server_hostname=HOST, http_path=HTTP_PATH, access_token=TOKEN) as conn:
    with conn.cursor() as cursor:
        cursor.execute("SELECT 1")
        print(cursor.fetchall())