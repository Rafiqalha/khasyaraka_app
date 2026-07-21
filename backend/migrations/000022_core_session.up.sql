CREATE TABLE learning_sessions (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    tenant_id VARCHAR(26) NOT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_sec INT DEFAULT 0
);

CREATE TABLE session_activities (
    session_id VARCHAR(26) REFERENCES learning_sessions(id) ON DELETE CASCADE,
    activity_id VARCHAR(26) NOT NULL,
    sequence INT NOT NULL,
    PRIMARY KEY (session_id, activity_id)
);
