-- Drop old tables because this is still unreleased
DROP TABLE IF EXISTS evidence_resolution_items CASCADE;
DROP TABLE IF EXISTS evidence_resolutions CASCADE;
DROP TABLE IF EXISTS evidences CASCADE;
DROP TABLE IF EXISTS observations CASCADE;
DROP TABLE IF EXISTS observation_candidates CASCADE;
DROP TABLE IF EXISTS prompt_assets CASCADE;

-- Model Registry
CREATE TABLE model_registry (
    id VARCHAR(26) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    provider VARCHAR(100) NOT NULL,
    version VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, provider, version)
);

-- Inference Profiles
CREATE TABLE inference_profiles (
    id VARCHAR(26) PRIMARY KEY,
    model_id VARCHAR(26) REFERENCES model_registry(id),
    name VARCHAR(255) NOT NULL,
    temperature FLOAT NOT NULL,
    top_p FLOAT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Prompt Assets & Bundles
CREATE TABLE prompt_assets (
    id VARCHAR(26) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, version)
);

CREATE TABLE prompt_bundles (
    id VARCHAR(26) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, version)
);

CREATE TABLE prompt_bundle_assets (
    bundle_id VARCHAR(26) REFERENCES prompt_bundles(id) ON DELETE CASCADE,
    asset_id VARCHAR(26) REFERENCES prompt_assets(id) ON DELETE CASCADE,
    sequence INT NOT NULL,
    PRIMARY KEY(bundle_id, asset_id)
);

-- Observation Candidates (Now with explicit Join Tables for Snapshots)
CREATE TABLE observation_candidates (
    id VARCHAR(26) PRIMARY KEY,
    session_id VARCHAR(26) NOT NULL,
    fingerprint VARCHAR(64) NOT NULL, -- Hash of all references
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE candidate_aggregates (
    candidate_id VARCHAR(26) REFERENCES observation_candidates(id) ON DELETE CASCADE,
    aggregate_id VARCHAR(26) NOT NULL,
    PRIMARY KEY(candidate_id, aggregate_id)
);

CREATE TABLE candidate_snapshots (
    candidate_id VARCHAR(26) REFERENCES observation_candidates(id) ON DELETE CASCADE,
    snapshot_type VARCHAR(100) NOT NULL, -- ARTIFACT, CAPABILITY, WORKSPACE
    snapshot_id VARCHAR(26) NOT NULL,
    PRIMARY KEY(candidate_id, snapshot_type, snapshot_id)
);

-- Observations (Lifecycle & Dual Fingerprints)
CREATE TABLE observations (
    id VARCHAR(26) PRIMARY KEY,
    candidate_id VARCHAR(26) REFERENCES observation_candidates(id),
    parent_observation_id VARCHAR(26) REFERENCES observations(id),
    prompt_bundle_id VARCHAR(26) REFERENCES prompt_bundles(id),
    model_id VARCHAR(26) REFERENCES model_registry(id),
    inference_profile_id VARCHAR(26) REFERENCES inference_profiles(id),
    
    input_fingerprint VARCHAR(64) NOT NULL,
    execution_fingerprint VARCHAR(64) NOT NULL,
    
    status VARCHAR(50) NOT NULL DEFAULT 'GENERATED', -- GENERATED, VALIDATED, ACCEPTED, SUPERSEDED
    
    observation_type VARCHAR(100) NOT NULL,
    confidence FLOAT NOT NULL,
    observation_quality FLOAT NOT NULL,
    summary TEXT NOT NULL,
    
    ai_latency_ms BIGINT,
    ai_cost FLOAT,
    ai_usage JSONB,
    ai_request_id VARCHAR(255),
    
    provenance JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE validation_reports (
    id VARCHAR(26) PRIMARY KEY,
    observation_id VARCHAR(26) REFERENCES observations(id) ON DELETE CASCADE,
    validator_name VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL, -- PASS, FAIL, WARNING
    duration_ms INT NOT NULL,
    warnings JSONB,
    errors JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE evidences (
    id VARCHAR(26) PRIMARY KEY,
    observation_id VARCHAR(26) REFERENCES observations(id) ON DELETE CASCADE,
    skill_id VARCHAR(100) NOT NULL,
    direction VARCHAR(50) NOT NULL,
    strength FLOAT NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
