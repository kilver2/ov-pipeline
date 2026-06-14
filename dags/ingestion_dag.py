# TODO: Verplaatsen download naar ingestion functions met subprocess, feestdagen incorperen voor parralel processing

from airflow.sdk import dag, Asset, task
from datetime import datetime

import requests
import zipfile
import subprocess
from pathlib import Path

from dags.assets import raw_gtfs, raw_feestdagen


SKIP_DOWNLOAD = True

PROJECT_ROOT = Path("/opt/airflow")

DATA_DIR = PROJECT_ROOT / "data"
GTFS_ZIP = DATA_DIR / "gtfs-nl.zip"
GTFS_FOLDER = DATA_DIR / "gtfs-nl"

GTFS_URL = "https://gtfs.ovapi.nl/nl/gtfs-nl.zip"

# Dag trigger één keer per dag
@dag(
    dag_id="ingestion_dag",
    start_date=datetime(2026, 6, 10),
    schedule="@daily",
    catchup=False,
    tags=["ingestion"],
)
def ingestion_dag():

    # Download alleen als skip_download false is voor DEV purposes
    @task
    def download_gtfs():

        if SKIP_DOWNLOAD:
            print("SKIP_DOWNLOAD=True -> download overgeslagen")
            return

        DATA_DIR.mkdir(parents=True, exist_ok=True)

        response = requests.get(GTFS_URL, timeout=300)
        response.raise_for_status()

        with open(GTFS_ZIP, "wb") as f:
            f.write(response.content)

    # uitpakken gtfs
    @task
    def extract_gtfs():

        if GTFS_FOLDER.exists() and (GTFS_FOLDER / "agency.txt").exists():
            print("GTFS al uitgepakt")
            return

        GTFS_FOLDER.mkdir(parents=True, exist_ok=True)

        with zipfile.ZipFile(GTFS_ZIP, "r") as zip_ref:
            zip_ref.extractall(GTFS_FOLDER)

    # Asset met call voor ingest functie
    @task(outlets=[raw_gtfs])
    def ingest_gtfs():

        subprocess.run(
            ["uv", "run", "ingestion/ingest_gtfs.py"],
            cwd=str(PROJECT_ROOT),
            check=True,
        )

    # Asset met call voor feestdagen ingest functie
    @task(outlets=[raw_feestdagen])
    def ingest_feestdagen():

        subprocess.run(
            ["uv", "run", "ingestion/ingest_feestdagen.py"],
            cwd=str(PROJECT_ROOT),
            check=True,
        )

    # Opzetten dag flow
    gtfs_download = download_gtfs()
    gtfs_extract = extract_gtfs()
    gtfs_ingest = ingest_gtfs()

    feestdagen = ingest_feestdagen()

    gtfs_download >> gtfs_extract >> gtfs_ingest
    

ingestion_dag()