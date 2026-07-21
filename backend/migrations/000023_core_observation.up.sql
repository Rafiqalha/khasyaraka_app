CREATE TABLE prompt_assets (
    id VARCHAR(26) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, version)
);

CREATE TABLE observation_candidates (
    id VARCHAR(26) PRIMARY KEY,
    session_id VARCHAR(26) NOT NULL,
    aggregate_id VARCHAR(26) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE observations (
    id VARCHAR(26) PRIMARY KEY,
    candidate_id VARCHAR(26) REFERENCES observation_candidates(id),
    parent_observation_id VARCHAR(26) REFERENCES observations(id),
    prompt_asset_id VARCHAR(26) REFERENCES prompt_assets(id),
    model VARCHAR(100) NOT NULL,
    fingerprint VARCHAR(64) NOT NULL,
    observation_type VARCHAR(100) NOT NULL,
    confidence FLOAT NOT NULL,
    observation_quality FLOAT NOT NULL,
    summary TEXT NOT NULL,
    provenance JSONB NOT NULL,
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
