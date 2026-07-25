-- learning_episodes is the root entity tracking a continuous 30-90m session
CREATE TABLE IF NOT EXISTS learning_episodes (
    id UUID PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    schema_version VARCHAR(50) NOT NULL,
    episode_version INT NOT NULL DEFAULT 1,
    activity_id VARCHAR(255),
    mission_id VARCHAR(255),
    intent_evolution JSONB, -- tracks how intents changed during this episode
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- episode_events stores raw interactions and cognitive events
CREATE TABLE IF NOT EXISTS episode_events (
    id UUID PRIMARY KEY,
    episode_id UUID NOT NULL REFERENCES learning_episodes(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_ms INT,
    payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- episode_snapshots stores workspace, environment, capability states
CREATE TABLE IF NOT EXISTS episode_snapshots (
    id UUID PRIMARY KEY,
    episode_id UUID NOT NULL REFERENCES learning_episodes(id) ON DELETE CASCADE,
    snapshot_type VARCHAR(100) NOT NULL, -- workspace, capability, context
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- episode_evaluations stores Ground Truth and performance evaluation
CREATE TABLE IF NOT EXISTS episode_evaluations (
    id UUID PRIMARY KEY,
    episode_id UUID NOT NULL REFERENCES learning_episodes(id) ON DELETE CASCADE,
    ground_truth JSONB, -- The optimal/expected solution and rubric
    evaluation JSONB,   -- The actual user performance (pass/fail, attempts, time)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- episode_reflections stores explicit reasoning from the user
CREATE TABLE IF NOT EXISTS episode_reflections (
    id UUID PRIMARY KEY,
    episode_id UUID NOT NULL REFERENCES learning_episodes(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_episodes_user ON learning_episodes(user_id);
CREATE INDEX idx_events_episode ON episode_events(episode_id);
CREATE INDEX idx_snapshots_episode ON episode_snapshots(episode_id);
