# TODO incremental load met ingested dates en is_incremental

import requests
import base64
import io
from databricks import sql
import pandas as pd
from dotenv import load_dotenv
import os

load_dotenv()

HOST = os.getenv("DATABRICKS_HOST")
TOKEN = os.getenv("DATABRICKS_TOKEN")
HTTP_PATH = os.getenv("DATABRICKS_HTTP_PATH")
REST_HOST = f"https://{HOST}"

# Dataframe omzetten naar Parquet, voor betere opslag in Databricks
def upload_parquet(df: pd.DataFrame, table_name: str):
    buffer = io.BytesIO()
    df.to_parquet(buffer, index=False)
    buffer.seek(0)

    # DBFS niet beschikbaar in databricks free
    requests.put(
        f"{REST_HOST}/api/2.0/fs/files/Volumes/ov-pipeline/raw/files/{table_name}.parquet",
        headers={
            "Authorization": f"Bearer {TOKEN}",
            "Content-Type": "application/octet-stream"
        },
        data=buffer.read()
    ).raise_for_status()

# Aanamaken van tabel in Databricks
def create_table(table_name: str):
    with sql.connect(server_hostname=HOST, http_path=HTTP_PATH, access_token=TOKEN) as conn:
        with conn.cursor() as cursor:
            # COR want je wil geen duplicates
            cursor.execute(f"""
                CREATE OR REPLACE TABLE `ov-pipeline`.raw.{table_name}
                USING DELTA
                AS SELECT * FROM parquet.`/Volumes/ov-pipeline/raw/files/{table_name}.parquet`
            """)