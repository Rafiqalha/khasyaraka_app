ALTER TABLE competency_projections
DROP COLUMN status,
DROP COLUMN governance_bundle_id,
DROP COLUMN confidence,
DROP COLUMN trend,
DROP COLUMN velocity,
DROP COLUMN stability,
DROP COLUMN forecast_30_days,
DROP COLUMN forecast_90_days,
DROP COLUMN metrics_json,
DROP COLUMN explanation_json,
DROP COLUMN expires_at;

DROP TABLE IF EXISTS projection_jobs;
DROP TABLE IF EXISTS governance_bundles;
DROP TABLE IF EXISTS projection_formulas;
DROP TABLE IF EXISTS competency_contributions;

ALTER TABLE competency_projections DROP COLUMN knowledge_lineage_id;
ALTER TABLE evidences DROP COLUMN knowledge_lineage_id;
ALTER TABLE observations DROP COLUMN knowledge_lineage_id;
ALTER TABLE observation_candidates DROP COLUMN knowledge_lineage_id;
ALTER TABLE activity_aggregates DROP COLUMN knowledge_lineage_id;
ALTER TABLE learning_activities DROP COLUMN knowledge_lineage_id;
