CREATE TABLE knowledge_epochs (
    id VARCHAR(26) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    fingerprint VARCHAR(64) NOT NULL UNIQUE,
    ontology_version_id VARCHAR(26) NOT NULL,
    governance_bundle_id VARCHAR(26) NOT NULL,
    projection_formula_id VARCHAR(26) NOT NULL,
    prompt_bundle_id VARCHAR(26),
    model_registry_id VARCHAR(26),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE epoch_compatibilities (
    id VARCHAR(26) PRIMARY KEY,
    epoch_id VARCHAR(26) REFERENCES knowledge_epochs(id) ON DELETE CASCADE,
    compatible_entity_type VARCHAR(50) NOT NULL, -- Ontology, PromptBundle, Model
    compatible_entity_version VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE replay_certifications (
    id VARCHAR(26) PRIMARY KEY,
    epoch_id VARCHAR(26) REFERENCES knowledge_epochs(id) ON DELETE CASCADE,
    success_rate FLOAT NOT NULL,
    determinism_score FLOAT NOT NULL,
    duration_ms INT NOT NULL,
    projection_accuracy FLOAT NOT NULL,
    fingerprint_match BOOLEAN NOT NULL,
    epoch_match BOOLEAN NOT NULL,
    status VARCHAR(50) NOT NULL, -- CERTIFIED, FAILED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
