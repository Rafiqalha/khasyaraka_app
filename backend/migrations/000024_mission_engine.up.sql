CREATE TABLE IF NOT EXISTS missions (
    id         VARCHAR(30) PRIMARY KEY,
    user_id    BIGINT NOT NULL REFERENCES users(id),
    persona    VARCHAR(20) NOT NULL DEFAULT 'beginner',
    objective  TEXT NOT NULL DEFAULT '',
    narrative  TEXT NOT NULL DEFAULT '',
    status     VARCHAR(20) NOT NULL DEFAULT 'active',
    score      INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS mission_events (
    id          BIGSERIAL PRIMARY KEY,
    mission_id  VARCHAR(30) NOT NULL REFERENCES missions(id),
    event_type  VARCHAR(30) NOT NULL,
    severity    VARCHAR(20) NOT NULL DEFAULT 'info',
    message     TEXT NOT NULL DEFAULT '',
    timestamp   VARCHAR(10) NOT NULL DEFAULT '',
    server_id   VARCHAR(20) DEFAULT '',
    source_ip   VARCHAR(20) DEFAULT '',
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mission_events_mission_id ON mission_events(mission_id);
