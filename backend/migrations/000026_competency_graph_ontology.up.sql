-- Alter Governance Policies
ALTER TABLE governance_policies 
ADD COLUMN effective_from TIMESTAMP WITH TIME ZONE,
ADD COLUMN effective_until TIMESTAMP WITH TIME ZONE;

-- Alter Evidence Resolutions
ALTER TABLE evidence_resolutions
ADD COLUMN strategy_id VARCHAR(26),
ADD COLUMN rule_id VARCHAR(26),
ADD COLUMN policy_id VARCHAR(26);

-- Refactor Skill Ontology to Identity + Version
DROP TABLE skill_ontology_relations;
DROP TABLE skill_ontology_nodes;

CREATE TABLE skill_ontology_identities (
    id VARCHAR(26) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE skill_ontology_versions (
    id VARCHAR(26) PRIMARY KEY,
    version VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(version)
);

CREATE TABLE skill_ontology_nodes (
    id VARCHAR(26) PRIMARY KEY,
    identity_id VARCHAR(26) REFERENCES skill_ontology_identities(id) ON DELETE CASCADE,
    version_id VARCHAR(26) REFERENCES skill_ontology_versions(id) ON DELETE CASCADE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(identity_id, version_id)
);

CREATE TABLE skill_ontology_relations (
    id VARCHAR(26) PRIMARY KEY,
    parent_node_id VARCHAR(26) REFERENCES skill_ontology_nodes(id) ON DELETE CASCADE,
    child_node_id VARCHAR(26) REFERENCES skill_ontology_nodes(id) ON DELETE CASCADE,
    influence_weight FLOAT NOT NULL DEFAULT 1.0,
    confidence_weight FLOAT NOT NULL DEFAULT 1.0,
    propagation_type VARCHAR(50) NOT NULL DEFAULT 'DIRECT', -- DIRECT, INDIRECT
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(parent_node_id, child_node_id)
);

-- Competency Graph Domain
CREATE TABLE capability_deltas (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    skill_node_id VARCHAR(26) REFERENCES skill_ontology_nodes(id),
    delta_source VARCHAR(50) NOT NULL, -- Observation, Assessment, Certification
    source_reference_id VARCHAR(26), -- e.g. Evidence ID
    delta_value FLOAT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE competency_projections (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    skill_node_id VARCHAR(26) REFERENCES skill_ontology_nodes(id),
    score FLOAT NOT NULL,
    
    ontology_version_id VARCHAR(26) REFERENCES skill_ontology_versions(id),
    policy_id VARCHAR(26),
    strategy_id VARCHAR(26),
    
    root_fingerprint VARCHAR(64) NOT NULL,
    snapshot_id VARCHAR(26),
    
    projected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE capability_snapshots (
    id VARCHAR(26) PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL,
    manifest JSONB NOT NULL, -- Projection Version, Policy Version, Strategy Version
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
