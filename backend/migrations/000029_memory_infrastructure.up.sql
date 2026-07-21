-- Memory Domain Infrastructure
CREATE TABLE memory_candidates (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    session_id VARCHAR(26),
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    competency_delta_id VARCHAR(26), -- Source trigger
    payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE memory_events (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    candidate_id VARCHAR(26) REFERENCES memory_candidates(id),
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    memory_type VARCHAR(50) NOT NULL, -- Semantic, Episodic, Procedural
    strength FLOAT NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE memory_projections (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    memory_node_id VARCHAR(26) NOT NULL, -- Logical grouping of memories
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    retention_score FLOAT NOT NULL,
    memory_state VARCHAR(50) NOT NULL, -- WORKING, SHORT_TERM, LONG_TERM
    forgetting_curve_json JSONB,
    status VARCHAR(50) NOT NULL DEFAULT 'FRESH',
    expires_at TIMESTAMP WITH TIME ZONE,
    projected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
