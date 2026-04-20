/* @bruin
name: env_feature_store.environmental_features
type: bq.sql
connection: bq-default
depends:
  - env_feature_store.weather_raw
  - env_feature_store.air_quality_raw
materialization:
  type: view
@bruin */

WITH clean_weather AS (
    SELECT
        time,
        extracted_at,

        -- KOREKSI OTOMATIS 1: Suhu
        -- Jika suhu di luar nalar manusia (-20 hingga 60 C), ubah jadi NULL (kosong).
        -- Jika normal, biarkan apa adanya.
        CASE
            WHEN temperature_2m BETWEEN -20 AND 60 THEN temperature_2m
            ELSE NULL
        END AS temperature_2m,

        -- KOREKSI OTOMATIS 2: Kelembapan
        -- Memaksa (Coercion) kelembapan tidak mungkin kurang dari 0 dan tidak lebih dari 100.
        -- Contoh: Jika sensor mengirim 105, otomatis dipotong jadi 100. Jika -5, jadi 0.
        LEAST(GREATEST(relative_humidity_2m, 0.0), 100.0) AS relative_humidity_2m

    FROM env_feature_store.weather_raw
    QUALIFY ROW_NUMBER() OVER (PARTITION BY time ORDER BY extracted_at DESC) = 1
),
clean_aq AS (
    SELECT
        time,
        extracted_at,

        -- KOREKSI OTOMATIS 3: Polusi Udara
        -- Polusi tidak mungkin minus. Jika sensor rusak mengirim nilai minus, paksa jadi 0.
        GREATEST(pm10, 0.0) AS pm10,
        GREATEST(pm2_5, 0.0) AS pm2_5

    FROM env_feature_store.air_quality_raw
    QUALIFY ROW_NUMBER() OVER (PARTITION BY time ORDER BY extracted_at DESC) = 1
)

SELECT
    w.time AS observation_time,
    w.temperature_2m,
    w.relative_humidity_2m,
    aq.pm10,
    aq.pm2_5,
    -- Label AI tetap bergantung pada data yang sudah dikoreksi
    CASE WHEN aq.pm2_5 > 55.4 THEN 1 ELSE 0 END AS is_hazardous,
    CURRENT_TIMESTAMP() AS processed_at
FROM clean_weather w
JOIN clean_aq aq ON w.time = aq.time