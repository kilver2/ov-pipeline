from datetime import datetime
import subprocess
from airflow.sdk import dag, Asset, task

from dags.assets import raw_gtfs, raw_feestdagen, standardized_layer

# Event driven trigger op raw_gtfs en raw_feestdagen assets uit ingestion_dag
@dag(
    dag_id="standardized_dag",
    start_date=datetime(2026, 6, 10),
    schedule=[raw_gtfs, raw_feestdagen],
    catchup=False,
    tags=["dbt", "standardized"],
)
def standardized_dag():
    
    # Deps installeren
    @task
    def dbt_deps():
        subprocess.run(
            ["dbt", "deps"],
            cwd="/opt/airflow/dbt",
            check=True,
        )

    # dbt run voor standard
    @task
    def dbt_run_standardized():
        subprocess.run(
            [
                "dbt",
                "run",
                "--select",
                "models/standardized"
            ],
            cwd="/opt/airflow/dbt",
            check=True,
        )

    # dbt test voor standard
    @task
    def dbt_test_standardized():
        subprocess.run(
            [
                "dbt",
                "test",
                "--select",
                "models/standardized"
            ],
            cwd="/opt/airflow/dbt",
            check=True,
        )

    # Extra completion task zodat er wordt gewacht op voltooien van run EN test
    @task(outlets=[standardized_layer])
    def publish_asset():
        print("Standardized layer klaar")

    dbt_deps() >> dbt_run_standardized() >> dbt_test_standardized() >> publish_asset()


standardized_dag()