-- Orchestrator Intelligence Infrastructure
CREATE TABLE intelligence_contexts (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    epoch_id VARCHAR(26) NOT NULL,
    memory_state_json JSONB,
    roadmap_state_json JSONB,
    career_state_json JSONB,
    portfolio_state_json JSONB,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_intel_ctx_user_epoch ON intelligence_contexts(user_id, epoch_id);

CREATE TABLE intelligence_directives (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    context_id VARCHAR(26) REFERENCES intelligence_contexts(id),
    epoch_id VARCHAR(26) NOT NULL,
    action_type VARCHAR(50) NOT NULL, -- URGENT_REVIEW, PORTFOLIO_BUILDING, RESUME_ROADMAP
    priority_score FLOAT NOT NULL,
    directive_payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
