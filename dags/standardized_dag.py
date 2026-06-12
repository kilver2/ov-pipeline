from datetime import datetime
import subprocess
from airflow.sdk import dag, Asset, task

from dags.assets import raw_gtfs, raw_feestdagen, standardized_layer


@dag(
    dag_id="standardized_dag",
    start_date=datetime(2025, 1, 1),
    schedule=[raw_gtfs, raw_feestdagen],
    catchup=False,
    tags=["dbt", "standardized"],
)
def standardized_dag():

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

    @task(outlets=[standardized_layer])
    def publish_asset():
        print("Standardized layer klaar")

    dbt_run_standardized() >> dbt_test_standardized() >> publish_asset()


standardized_dag()