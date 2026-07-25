CREATE TABLE submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    correlation_id VARCHAR(100) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
    learning_session_id VARCHAR(100) NOT NULL,
    mission_id VARCHAR(100) NOT NULL,
    node_id VARCHAR(100) NOT NULL,
    attempt_number INT NOT NULL DEFAULT 1,
    priority VARCHAR(50) NOT NULL DEFAULT 'default',
    status VARCHAR(50) NOT NULL,
    idempotency_key VARCHAR(100) UNIQUE,
    
    -- Versioning
    rule_set_version VARCHAR(50),
    evaluator_version VARCHAR(50),
    policy_version VARCHAR(50),
    curriculum_version VARCHAR(50),
    mission_version VARCHAR(50),
    sandbox_image VARCHAR(100),
    
    -- Diagnostics & Tracking
    worker_id VARCHAR(100),
    queue_name VARCHAR(100),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    queued_at TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_submissions_idempotency ON submissions(idempotency_key);
CREATE INDEX idx_submissions_correlation ON submissions(correlation_id);
CREATE INDEX idx_submissions_user_session ON submissions(user_id, learning_session_id);

CREATE TABLE submission_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
    event_id VARCHAR(100) NOT NULL,
    sequence_number INT NOT NULL,
    previous_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    duration_ms INT,
    actor VARCHAR(100),
    payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(submission_id, sequence_number)
);

CREATE INDEX idx_submission_events_submission ON submission_events(submission_id);
