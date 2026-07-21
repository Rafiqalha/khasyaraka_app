-- 1. Master Tables
CREATE TABLE domains (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_id UUID REFERENCES domains(id) ON DELETE CASCADE,
    slug VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT
);

-- 2. Capability Profile (Current State)
CREATE TABLE learner_capabilities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    skill_id UUID REFERENCES skills(id) ON DELETE CASCADE,
    
    -- High resolution internal score (0-1000)
    proficiency_score INT DEFAULT 0,
    
    -- Amount of evidence gathered (0.0 to 1.0)
    evidence_score DECIMAL(3,2) DEFAULT 0.00,
    
    last_assessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, skill_id)
);

-- 3. Capability Evaluation Logs (History for Memory Engine)
CREATE TABLE capability_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    capability_id UUID REFERENCES learner_capabilities(id) ON DELETE CASCADE,
    source_type VARCHAR(50), -- 'Mission', 'Conversation', 'Project'
    source_id UUID,          -- ID dari Mission, Conversation, dll
    delta_score INT,         -- Perubahan skor (+3, -1, dll)
    summary VARCHAR(500),    -- Justifikasi singkat untuk UI/Memory
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
