"""@bruin
name: env_feature_store.weather_to_gcs
type: python
image: python:3.10
connection: bq-default
@bruin"""

import os
import requests
import pandas as pd
from datetime import datetime

# Ambil tanggal dari Bruin
start = os.environ.get("BRUIN_START_DATE", "2024-01-01")
end = os.environ.get("BRUIN_END_DATE", "2024-01-01")
lat, lon = -6.3024, 107.2952

# Tarik API
url = "https://archive-api.open-meteo.com/v1/archive"
params = {
    "latitude": lat, "longitude": lon,
    "start_date": start, "end_date": end,
    "hourly": "temperature_2m,relative_humidity_2m",
    "timezone": "Asia/Jakarta"
}
response = requests.get(url, params=params)
df = pd.DataFrame(response.json()["hourly"])
df["time"] = pd.to_datetime(df["time"])
df["extracted_at"] = datetime.now()

# Simpan ke GCS Data Lake
bucket_name = "env-raw-data"
file_path = f"gs://{bucket_name}/weather/weather_{start}_to_{end}.parquet"

# Pandas akan otomatis menggunakan kunci gcp-service-account.json kita
df.to_parquet(file_path, index=False)
print(f"Data Cuaca mentah berhasil didaratkan di: {file_path}")