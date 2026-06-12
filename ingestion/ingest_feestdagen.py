import requests
import pandas as pd
from utils import upload_parquet, create_table

JAREN = [2025, 2026]

def fetch_feestdagen(jaar: int) -> pd.DataFrame:
    response = requests.get(f"https://date.nager.at/api/v3/PublicHolidays/{jaar}/NL")
    response.raise_for_status()
    df = pd.DataFrame(response.json())
    df["jaar"] = jaar
    return df

if __name__ == "__main__":
    df = pd.concat([fetch_feestdagen(jaar) for jaar in JAREN], ignore_index=True)
    df.columns = [col.lower().strip() for col in df.columns]
    upload_parquet(df, "raw_feestdagen")
    create_table("raw_feestdagen")
    print(f"Done: raw_feestdagen ({len(df)} rows)")