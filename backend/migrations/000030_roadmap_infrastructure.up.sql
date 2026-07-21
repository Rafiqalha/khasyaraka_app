-- Roadmap Intelligence Infrastructure
CREATE TABLE roadmap_candidates (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    trigger_type VARCHAR(50) NOT NULL, -- MEMORY_DECAY, COMPETENCY_ACHIEVED, USER_INTENT
    trigger_ref_id VARCHAR(26),
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roadmap_events (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    candidate_id VARCHAR(26) REFERENCES roadmap_candidates(id),
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    action_type VARCHAR(50) NOT NULL, -- ADD_NODE, REMOVE_NODE, REPRIORITIZE
    node_id VARCHAR(26) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roadmap_projections (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    knowledge_lineage_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    active_nodes_json JSONB NOT NULL, -- The ordered list of nodes the user should traverse
    status VARCHAR(50) NOT NULL DEFAULT 'FRESH',
    projected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
