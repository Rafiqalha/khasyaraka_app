-- Drop old evidences table as we are reinventing it in a separate domain
DROP TABLE IF EXISTS evidences CASCADE;

-- Governance Layer
CREATE TABLE governance_policies (
    id VARCHAR(26) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    config JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE governance_rules (
    id VARCHAR(26) PRIMARY KEY,
    policy_id VARCHAR(26) REFERENCES governance_policies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    condition JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE governance_strategies (
    id VARCHAR(26) PRIMARY KEY,
    name VARCHAR(255) NOT NULL, -- e.g., 'BayesianUpdate', 'ExponentialDecay'
    parameters JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Skill Ontology
CREATE TABLE skill_ontology_nodes (
    id VARCHAR(26) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE skill_ontology_relations (
    id VARCHAR(26) PRIMARY KEY,
    parent_node_id VARCHAR(26) REFERENCES skill_ontology_nodes(id) ON DELETE CASCADE,
    child_node_id VARCHAR(26) REFERENCES skill_ontology_nodes(id) ON DELETE CASCADE,
    relation_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(parent_node_id, child_node_id)
);

-- Evidence Engine
CREATE TABLE evidences (
    id VARCHAR(26) PRIMARY KEY,
    observation_id VARCHAR(26) NOT NULL, -- Reference to observation, not FK because domains are separate
    skill_node_id VARCHAR(26) REFERENCES skill_ontology_nodes(id),
    evidence_type VARCHAR(100) NOT NULL, -- Behavior, Knowledge, Performance, etc.
    status VARCHAR(50) NOT NULL DEFAULT 'GENERATED', -- GENERATED, VALIDATED, RESOLVED, EXPIRED, SUPERSEDED
    fingerprint VARCHAR(64) NOT NULL,
    
    direction VARCHAR(50) NOT NULL,
    strength FLOAT NOT NULL,
    reason TEXT NOT NULL,
    
    validity_end_at TIMESTAMP WITH TIME ZONE, -- Aging concept
    weight FLOAT DEFAULT 1.0, -- Default weight
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE evidence_resolutions (
    id VARCHAR(26) PRIMARY KEY,
    resolution_type VARCHAR(100) NOT NULL,
    winning_evidence_id VARCHAR(26) REFERENCES evidences(id),
    confidence FLOAT NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE evidence_resolution_items (
    resolution_id VARCHAR(26) REFERENCES evidence_resolutions(id) ON DELETE CASCADE,
    evidence_id VARCHAR(26) REFERENCES evidences(id) ON DELETE CASCADE,
    PRIMARY KEY(resolution_id, evidence_id)
);
