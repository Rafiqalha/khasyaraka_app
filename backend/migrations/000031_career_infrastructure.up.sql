-- Career Intelligence Infrastructure
CREATE TABLE career_candidates (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    trigger_type VARCHAR(50) NOT NULL, -- COMPETENCY_UPDATE, NEW_TARGET_ROLE, ROLE_ONTOLOGY_UPDATE
    trigger_ref_id VARCHAR(26),
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE career_events (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    candidate_id VARCHAR(26) REFERENCES career_candidates(id),
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    action_type VARCHAR(50) NOT NULL, -- GAP_DECREASED, GAP_INCREASED, ROLE_ACHIEVED, TARGET_SET
    target_role_id VARCHAR(26) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE career_projections (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    target_role_id VARCHAR(26) NOT NULL,
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    readiness_score FLOAT NOT NULL, -- 0 to 100 percentage
    gap_analysis_json JSONB NOT NULL, -- Detailed distance per skill
    status VARCHAR(50) NOT NULL DEFAULT 'FRESH',
    projected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
