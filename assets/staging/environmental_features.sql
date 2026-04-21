/* @bruin
name: env_feature_store.environmental_features
type: bq.sql
connection: bq-default
depends:
  - env_feature_store.weather_raw
  - env_feature_store.air_quality_raw
@bruin */

-- 1. Kita buat sebagai Tabel Fisik, bukan lagi sekadar SELECT
CREATE OR REPLACE TABLE `env_feature_store.environmental_features`
-- 2. IMPLEMENTASI PARTISI: Memecah tabel berdasarkan Hari
PARTITION BY DATE(observation_time)
-- 3. IMPLEMENTASI CLUSTERING: Mengelompokkan data berdasarkan label bahaya
CLUSTER BY is_hazardous
AS
WITH clean_weather AS (
    SELECT
        time,
        extracted_at,
        CASE WHEN temperature_2m BETWEEN -20 AND 60 THEN temperature_2m ELSE NULL END AS temperature_2m,
        LEAST(GREATEST(relative_humidity_2m, 0.0), 100.0) AS relative_humidity_2m
    FROM env_feature_store.weather_raw
    QUALIFY ROW_NUMBER() OVER (PARTITION BY time ORDER BY extracted_at DESC) = 1
),
clean_aq AS (
    SELECT
        time,
        extracted_at,
        GREATEST(pm10, 0.0) AS pm10,
        GREATEST(pm2_5, 0.0) AS pm2_5
    FROM env_feature_store.air_quality_raw
    QUALIFY ROW_NUMBER() OVER (PARTITION BY time ORDER BY extracted_at DESC) = 1
)

SELECT
    TIMESTAMP_SECONDS(CAST(w.time / 1000000000 AS INT64)) AS observation_time,
    w.temperature_2m,
    w.relative_humidity_2m,
    aq.pm10,
    aq.pm2_5,
    CASE WHEN aq.pm2_5 > 55.4 THEN 1 ELSE 0 END AS is_hazardous,
    CURRENT_TIMESTAMP() AS processed_at
FROM clean_weather w
JOIN clean_aq aq ON w.time = aq.time;