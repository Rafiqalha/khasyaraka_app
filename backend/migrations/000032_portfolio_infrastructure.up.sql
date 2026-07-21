-- Portfolio Intelligence Infrastructure
CREATE TABLE portfolio_candidates (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    trigger_type VARCHAR(50) NOT NULL, -- EVIDENCE_RESOLVED, USER_CURATION_INTENT
    trigger_ref_id VARCHAR(26),
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE portfolio_events (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    candidate_id VARCHAR(26) REFERENCES portfolio_candidates(id),
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    action_type VARCHAR(50) NOT NULL, -- ASSET_PUBLISHED, ASSET_WITHDRAWN, HIGHLIGHT_SET
    asset_id VARCHAR(26) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE portfolio_projections (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    public_showcase_json JSONB NOT NULL, -- The rendered portfolio
    status VARCHAR(50) NOT NULL DEFAULT 'FRESH',
    projected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
