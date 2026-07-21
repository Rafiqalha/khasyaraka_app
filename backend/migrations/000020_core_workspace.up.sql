CREATE TABLE workspaces (
    id VARCHAR(26) PRIMARY KEY,
    owner_type VARCHAR(50) NOT NULL,
    owner_id VARCHAR(26) NOT NULL,
    tenant_id VARCHAR(26) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE workspace_contexts (
    id VARCHAR(26) PRIMARY KEY,
    workspace_id VARCHAR(26) REFERENCES workspaces(id) ON DELETE CASCADE,
    context_type VARCHAR(50) NOT NULL,
    context_id VARCHAR(26) NOT NULL,
    metadata JSONB,
    metadata_version VARCHAR(20) DEFAULT 'v1'
);

CREATE TABLE workspace_artifacts (
    id VARCHAR(26) PRIMARY KEY,
    workspace_id VARCHAR(26) REFERENCES workspaces(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    artifact_type VARCHAR(50) NOT NULL, 
    artifact_state VARCHAR(50) DEFAULT 'ACTIVE',
    artifact_visibility VARCHAR(50) DEFAULT 'PRIVATE',
    artifact_version INT DEFAULT 1,
    storage_type VARCHAR(50) NOT NULL,  
    storage_ref TEXT NOT NULL,          
    metadata JSONB,                     
    metadata_version VARCHAR(20) DEFAULT 'v1',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE workspace_snapshots (
    id VARCHAR(26) PRIMARY KEY,
    workspace_id VARCHAR(26) REFERENCES workspaces(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL, 
    label VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE workspace_snapshot_artifacts (
    snapshot_id VARCHAR(26) REFERENCES workspace_snapshots(id) ON DELETE CASCADE,
    artifact_id VARCHAR(26) REFERENCES workspace_artifacts(id),
    artifact_version INT NOT NULL,
    PRIMARY KEY (snapshot_id, artifact_id)
);
