/* @bruin
name: env_feature_store.weather_raw
type: bq.sql
connection: bq-default
depends:
  - env_feature_store.weather_to_gcs
@bruin */

CREATE OR REPLACE EXTERNAL TABLE `env_feature_store.weather_raw`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://env-raw-data/weather/*.parquet']
);