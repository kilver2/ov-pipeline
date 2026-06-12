from airflow.sdk import dag, Asset, task
from datetime import datetime
import subprocess

from dags.assets import standardized_layer, reporting_layer


@dag(
    dag_id="reporting_dag",
    start_date=datetime(2025, 1, 1),
    schedule=[standardized_layer],
    catchup=False,
    tags=["dbt", "reporting"],
)
def reporting_dag():

    @task
    def dbt_run_reporting():
        subprocess.run(
            [
                "dbt",
                "run",
                "--select",
                "models/reporting"
            ],
            cwd="/opt/airflow/dbt",
            check=True,
        )

    @task
    def dbt_test_reporting():
        subprocess.run(
            [
                "dbt",
                "test",
                "--select",
                "models/reporting"
            ],
            cwd="/opt/airflow/dbt",
            check=True,
        )

    @task(outlets=[reporting_layer])
    def publish_asset():
        print("Reporting layer klaar")

    dbt_run_reporting() >> dbt_test_reporting() >> publish_asset()


reporting_dag()