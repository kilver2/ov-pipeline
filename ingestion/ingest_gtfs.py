import pandas as pd
from utils import upload_parquet, create_table
import os

GTFS_PATH = "data/gtfs-nl"

FILES = {
    "raw_agency": ("agency.txt", None),
    "raw_routes": ("routes.txt", None),
    "raw_stops": ("stops.txt", None),
    "raw_trips": ("trips.txt", None),
    "raw_calendar_dates": ("calendar_dates.txt", None),
}

if __name__ == "__main__":
    for table_name, (filename, sample_size) in FILES.items():
        df = pd.read_csv(os.path.join(GTFS_PATH, filename), dtype=str, nrows=sample_size)
        df.columns = [col.lower().strip() for col in df.columns]
        upload_parquet(df, table_name)
        create_table(table_name)
        print(f"Done: {table_name} ({len(df)} rows)")