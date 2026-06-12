from airflow.sdk import Asset

raw_gtfs = Asset("raw_gtfs")
raw_feestdagen = Asset("raw_feestdagen")

standardized_layer = Asset("standardized_layer")
reporting_layer = Asset("reporting_layer")