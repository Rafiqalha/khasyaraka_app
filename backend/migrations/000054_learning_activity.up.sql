CREATE TABLE learning_activities (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    tenant_id VARCHAR(26) NOT NULL,
    source_engine VARCHAR(50) NOT NULL,
    source_id VARCHAR(26) NOT NULL,
    artifact_id VARCHAR(26),
    activity_type VARCHAR(50) NOT NULL,
    payload JSONB,                      
    schema_version VARCHAR(20) DEFAULT 'v1',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
