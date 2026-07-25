-- 1. Competency Graph
CREATE TABLE competencies (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    difficulty INT DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Edges: REQUIRES, SUGGESTS, REINFORCES, OPTIONAL
CREATE TABLE competency_prerequisites (
    competency_id VARCHAR(255) REFERENCES competencies(id),
    prerequisite_id VARCHAR(255) REFERENCES competencies(id),
    relationship_type VARCHAR(50) DEFAULT 'REQUIRES',
    PRIMARY KEY (competency_id, prerequisite_id)
);

-- 2. Learning Paths & Pack Graphs
CREATE TABLE learning_paths (
    id VARCHAR(255) PRIMARY KEY,
    goal_id VARCHAR(255), -- Will reference learning_goals but omitting FK for loose coupling in MVP
    title VARCHAR(255) NOT NULL,
    description TEXT,
    path_type VARCHAR(50) -- e.g., Fast Track, University Track
);

CREATE TABLE path_packs (
    path_id VARCHAR(255) REFERENCES learning_paths(id),
    pack_id VARCHAR(255), -- References packs but omitting FK for loose coupling in MVP
    sequence_order INT DEFAULT 0,
    PRIMARY KEY (path_id, pack_id)
);

-- Packs contain Activities, Activities grant Competencies
CREATE TABLE pack_activities (
    id VARCHAR(255) PRIMARY KEY,
    pack_id VARCHAR(255),
    activity_type VARCHAR(50), -- Workspace, Assessment, Reflection, Arena
    title VARCHAR(255)
);

CREATE TABLE activity_competencies (
    activity_id VARCHAR(255) REFERENCES pack_activities(id),
    competency_id VARCHAR(255) REFERENCES competencies(id),
    weight DECIMAL(5,4) DEFAULT 1.0000,
    PRIMARY KEY (activity_id, competency_id)
);

-- 3. Personal Knowledge Graph (User State & Feature Vectors)
CREATE TABLE user_competencies (
    user_id BIGINT REFERENCES users(id),
    competency_id VARCHAR(255) REFERENCES competencies(id),
    mastery_score DECIMAL(5,4) DEFAULT 0.0000, 
    last_practiced_at TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (user_id, competency_id)
);

CREATE TABLE learning_feature_vectors (
    user_id BIGINT REFERENCES users(id),
    feature_key VARCHAR(255) NOT NULL, -- e.g., "visual_learning", "curiosity", "reflection"
    weight DECIMAL(5,4) DEFAULT 0.5000, -- 0.0 to 1.0 continuous scale
    PRIMARY KEY (user_id, feature_key)
);
