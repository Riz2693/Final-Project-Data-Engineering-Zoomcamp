/* @bruin
name: env_feature_store.hazard_predictions
type: bq.sql
connection: bq-default
materialization:
  type: view
depends:
  - env_feature_store.train_hazard_model
  - env_feature_store.environmental_features
@bruin */

SELECT
    * FROM
    ML.PREDICT(
        MODEL `env_feature_store.hazard_prediction_model`,
        (SELECT * FROM env_feature_store.environmental_features)
    );