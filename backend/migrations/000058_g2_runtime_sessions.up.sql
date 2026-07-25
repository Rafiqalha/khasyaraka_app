CREATE TABLE runtime_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    learning_goal_id VARCHAR(50) NOT NULL REFERENCES learning_goals(id) ON DELETE CASCADE,
    pack_id VARCHAR(50) NOT NULL,
    pack_version VARCHAR(50) NOT NULL,
    current_node_id VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    progress_percentage INT NOT NULL DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB
);

CREATE INDEX idx_runtime_sessions_user_id ON runtime_sessions(user_id);
CREATE INDEX idx_runtime_sessions_status ON runtime_sessions(status);
