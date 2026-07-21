-- 1. Core Identity Table
CREATE TABLE learner_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    display_name VARCHAR(100),
    birth_year INT,
    country VARCHAR(100),
    timezone VARCHAR(50),
    native_language VARCHAR(20),
    preferred_language VARCHAR(20),
    education_level VARCHAR(50),
    experience_level VARCHAR(50),
    
    -- Goal & Motivation
    career_slug VARCHAR(100),
    learning_goal_type VARCHAR(50),
    learning_goal_detail TEXT,
    motivation_type VARCHAR(50),
    motivation_text TEXT,
    
    -- Learning Preferences (Observable)
    daily_minutes INT DEFAULT 0,
    prefers_video BOOLEAN DEFAULT FALSE,
    prefers_text BOOLEAN DEFAULT FALSE,
    prefers_project BOOLEAN DEFAULT FALSE,
    prefers_quiz BOOLEAN DEFAULT FALSE,
    
    -- UX & AI specific
    ai_persona VARCHAR(50) DEFAULT 'mentor',
    current_stage VARCHAR(50) DEFAULT 'Discover',
    
    -- Versioning for AI Context
    persona_version VARCHAR(20) DEFAULT 'v1',
    identity_schema_version VARCHAR(20) DEFAULT 'v1',
    
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Device Registry
CREATE TABLE user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    platform VARCHAR(50),
    os VARCHAR(50),
    capability_score VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Relational Preferences
CREATE TABLE user_interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    interest VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
