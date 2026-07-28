CREATE TABLE IF NOT EXISTS pack_mission_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    pack_id TEXT NOT NULL,
    mission_id TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    ai_rules JSONB,
    workspace_state JSONB,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    score JSONB
);

CREATE INDEX IF NOT EXISTS idx_pack_mission_sessions_user ON pack_mission_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_pack_mission_sessions_pack ON pack_mission_sessions(pack_id);
