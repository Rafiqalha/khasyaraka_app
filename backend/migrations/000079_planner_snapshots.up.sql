CREATE TABLE IF NOT EXISTS planner_snapshots (
    id VARCHAR(50) PRIMARY KEY,
    enrollment_id VARCHAR(50) NOT NULL REFERENCES learning_enrollments(id) ON DELETE CASCADE,
    runtime_session_id VARCHAR(50),
    strategy_payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
