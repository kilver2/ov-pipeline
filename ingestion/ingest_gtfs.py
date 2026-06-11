import pandas as pd
import requests
from databricks import sql
from dotenv import load_dotenv
import os
import io
import base64


# Inladen van de env voor Databricks
load_dotenv()

HOST = os.getenv("DATABRICKS_HOST")
TOKEN = os.getenv("DATABRICKS_TOKEN")
HTTP_PATH = os.getenv("DATABRICKS_HTTP_PATH")
REST_HOST = f"https://{HOST}"
GTFS_PATH = "data/gtfs-nl"

# Files inladen, waren eerst met filter op aantal, nu niet meer
FILES = {
    "raw_agency": ("agency.txt", None),
    "raw_routes": ("routes.txt", None),
    "raw_stops": ("stops.txt", None),
    "raw_trips": ("trips.txt", None),
    "raw_calendar_dates": ("calendar_dates.txt", None),
}

# Verander de dataframe naar parquet en upload de files
def upload_parquet(df: pd.DataFrame, table_name: str):
    buffer = io.BytesIO()
    df.to_parquet(buffer, index=False)
    buffer.seek(0)

    requests.put(
        f"{REST_HOST}/api/2.0/fs/files/Volumes/ov-pipeline/raw/files/{table_name}.parquet",
        headers={
            "Authorization": f"Bearer {TOKEN}",
            "Content-Type": "application/octet-stream"
        },
        data=buffer.read()
    ).raise_for_status()

# Maak/vervang de tabel met de data uit de parquet files
def create_table(table_name: str):
    with sql.connect(server_hostname=HOST, http_path=HTTP_PATH, access_token=TOKEN) as conn:
        with conn.cursor() as cursor:
            cursor.execute(f"""
                CREATE OR REPLACE TABLE `ov-pipeline`.raw.{table_name}
                USING DELTA
                AS SELECT * FROM parquet.`/Volumes/ov-pipeline/raw/files/{table_name}.parquet`
            """)

# Trigger
if __name__ == "__main__":
    for table_name, (filename, sample_size) in FILES.items():
        df = pd.read_csv(os.path.join(GTFS_PATH, filename), dtype=str, nrows=sample_size)
        df.columns = [col.lower().strip() for col in df.columns]
        upload_parquet(df, table_name)
        create_table(table_name)
        print(f"Done: {table_name} ({len(df)} rows)")