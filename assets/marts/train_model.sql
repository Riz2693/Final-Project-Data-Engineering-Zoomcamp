/* @bruin
name: env_feature_store.train_hazard_model
type: bq.sql
connection: bq-default
depends:
  - env_feature_store.environmental_features
@bruin */

CREATE OR REPLACE MODEL `env_feature_store.hazard_prediction_model`
OPTIONS(model_type='LOGISTIC_REG', input_label_cols=['is_hazardous']) AS
SELECT
    temperature_2m,
    relative_humidity_2m,
    pm10,
    pm2_5,
    is_hazardous
FROM env_feature_store.environmental_features;