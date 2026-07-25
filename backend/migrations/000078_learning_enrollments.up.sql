CREATE TABLE IF NOT EXISTS learning_enrollments (
    id VARCHAR(50) PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    academy_id VARCHAR(50) NOT NULL REFERENCES academies(id),
    specialization_id VARCHAR(50) NOT NULL REFERENCES specializations(id),
    blueprint_version VARCHAR(20),
    status VARCHAR(20) DEFAULT 'ACTIVE', -- ACTIVE, COMPLETED, PAUSED
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, specialization_id)
);
