CREATE TABLE IF NOT EXISTS academies (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    icon VARCHAR(50) NOT NULL,
    color_theme VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS domains (
    id VARCHAR(50) PRIMARY KEY,
    academy_id VARCHAR(50) NOT NULL REFERENCES academies(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS specializations (
    id VARCHAR(50) PRIMARY KEY,
    domain_id VARCHAR(50) NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS learning_goals (
    id VARCHAR(50) PRIMARY KEY,
    specialization_id VARCHAR(50) NOT NULL REFERENCES specializations(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    learning_objective TEXT,
    goal_type VARCHAR(50) DEFAULT 'SKILL',
    latest_pack_id VARCHAR(50), -- Will reference packs(id), added constraint later
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS packs (
    id VARCHAR(50) PRIMARY KEY,
    learning_goal_id VARCHAR(50) NOT NULL REFERENCES learning_goals(id) ON DELETE CASCADE,
    version VARCHAR(20) NOT NULL,
    manifest JSONB NOT NULL,
    storage_url VARCHAR(255) NOT NULL,
    checksum VARCHAR(64) NOT NULL,
    signature VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT', -- DRAFT, PUBLISHED, DEPRECATED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(learning_goal_id, version)
);

-- Add foreign key constraint to learning_goals
ALTER TABLE learning_goals ADD CONSTRAINT fk_learning_goal_latest_pack FOREIGN KEY (latest_pack_id) REFERENCES packs(id) ON DELETE SET NULL;

-- Initial Seed Data for Cyber Academy
INSERT INTO academies (id, title, description, icon, color_theme) VALUES 
('cyber', 'Cyber Academy', 'Dari Sandi Pramuka ke Dunia Siber.', 'security', 'blue')
ON CONFLICT (id) DO NOTHING;

INSERT INTO domains (id, academy_id, title, description) VALUES 
('defensive-security', 'cyber', 'Defensive Security', 'Belajar cara bertahan dari serangan siber.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO specializations (id, domain_id, title, description) VALUES 
('soc-analyst', 'defensive-security', 'SOC Analyst', 'Menjadi analis keamanan siber level pertama.')
ON CONFLICT (id) DO NOTHING;
