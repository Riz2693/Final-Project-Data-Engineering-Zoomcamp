"""@bruin
name: env_feature_store.air_quality_to_gcs
type: python
image: python:3.10
connection: bq-default
@bruin"""

import os
import requests
import pandas as pd
from datetime import datetime

start = os.environ.get("BRUIN_START_DATE", "2024-01-01")
end = os.environ.get("BRUIN_END_DATE", "2024-01-01")
lat, lon = -6.3024, 107.2952

url = "https://air-quality-api.open-meteo.com/v1/air-quality"
params = {
    "latitude": lat, "longitude": lon,
    "start_date": start, "end_date": end,
    "hourly": "pm10,pm2_5",
    "timezone": "Asia/Jakarta"
}
response = requests.get(url, params=params)
df = pd.DataFrame(response.json()["hourly"])
df["time"] = pd.to_datetime(df["time"])
df["extracted_at"] = datetime.now()

bucket_name = "env-raw-data"
file_path = f"gs://{bucket_name}/air_quality/aq_{start}_to_{end}.parquet"
df.to_parquet(file_path, index=False)
print(f"Data Polusi mentah berhasil didaratkan di: {file_path}")