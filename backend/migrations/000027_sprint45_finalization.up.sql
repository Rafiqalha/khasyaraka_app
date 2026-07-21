-- Knowledge Lineage ID integration across reasoning pipeline
ALTER TABLE learning_activities ADD COLUMN knowledge_lineage_id VARCHAR(26);
ALTER TABLE activity_aggregates ADD COLUMN knowledge_lineage_id VARCHAR(26);
ALTER TABLE observation_candidates ADD COLUMN knowledge_lineage_id VARCHAR(26);
ALTER TABLE observations ADD COLUMN knowledge_lineage_id VARCHAR(26);
ALTER TABLE evidences ADD COLUMN knowledge_lineage_id VARCHAR(26);
ALTER TABLE competency_projections ADD COLUMN knowledge_lineage_id VARCHAR(26);

-- Competency Contributions (Immutable Event translating Evidence)
CREATE TABLE competency_contributions (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    evidence_id VARCHAR(26) NOT NULL,
    skill_node_id VARCHAR(26) NOT NULL,
    knowledge_lineage_id VARCHAR(26),
    kind VARCHAR(50) NOT NULL,
    magnitude FLOAT NOT NULL,
    confidence FLOAT NOT NULL,
    weight FLOAT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Governance Bundles & Projection Formulas
CREATE TABLE projection_formulas (
    id VARCHAR(26) PRIMARY KEY,
    version VARCHAR(50) NOT NULL,
    hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE governance_bundles (
    id VARCHAR(26) PRIMARY KEY,
    fingerprint VARCHAR(64) NOT NULL UNIQUE,
    policy_id VARCHAR(26),
    ontology_version_id VARCHAR(26),
    propagation_strategy_id VARCHAR(26),
    decay_strategy_id VARCHAR(26),
    projection_formula_id VARCHAR(26),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Projection Scheduler Jobs
CREATE TABLE projection_jobs (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    priority VARCHAR(50) NOT NULL, -- HIGH, NORMAL, LOW
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    reason VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE
);

-- Alter Competency Projections to Cache State
ALTER TABLE competency_projections
ADD COLUMN status VARCHAR(50) NOT NULL DEFAULT 'FRESH', -- FRESH, EXPIRED, INVALIDATED, REBUILDING
ADD COLUMN governance_bundle_id VARCHAR(26) REFERENCES governance_bundles(id),
ADD COLUMN confidence FLOAT DEFAULT 0.0,
ADD COLUMN trend VARCHAR(50) DEFAULT 'STABLE',
ADD COLUMN velocity FLOAT DEFAULT 0.0,
ADD COLUMN stability VARCHAR(50) DEFAULT 'UNKNOWN',
ADD COLUMN forecast_30_days FLOAT,
ADD COLUMN forecast_90_days FLOAT,
ADD COLUMN metrics_json JSONB,
ADD COLUMN explanation_json JSONB,
ADD COLUMN expires_at TIMESTAMP WITH TIME ZONE;
