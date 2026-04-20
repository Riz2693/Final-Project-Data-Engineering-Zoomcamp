/* @bruin
name: env_feature_store.air_quality_raw
type: bq.sql
connection: bq-default
depends:
  - env_feature_store.air_quality_to_gcs
@bruin */

CREATE OR REPLACE EXTERNAL TABLE `env_feature_store.air_quality_raw`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://env-raw-data/air_quality/*.parquet']
);