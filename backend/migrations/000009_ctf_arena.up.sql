-- CTF Room extended state
CREATE TABLE IF NOT EXISTS ctf_rooms (
    id              BIGSERIAL PRIMARY KEY,
    room_id         BIGINT NOT NULL REFERENCES rooms(id) 
                    ON DELETE CASCADE,
    phase           VARCHAR(20) NOT NULL DEFAULT 'waiting',
                    -- waiting/defense/attack/patching/finished
    phase_started_at TIMESTAMPTZ,
    defense_duration_sec INT NOT NULL DEFAULT 180,
    attack_duration_sec  INT NOT NULL DEFAULT 300,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(room_id)
);

-- Each team's CTF data
CREATE TABLE IF NOT EXISTS ctf_teams (
    id              BIGSERIAL PRIMARY KEY,
    ctf_room_id     BIGINT NOT NULL REFERENCES ctf_rooms(id)
                    ON DELETE CASCADE,
    team_id         BIGINT NOT NULL REFERENCES teams(id),
    flag            VARCHAR(100) NOT NULL DEFAULT '',
                    -- FORMAT: FLAG{PRADIGI_XXXXXX}
    defense_image_url TEXT NOT NULL DEFAULT '',
                    -- URL of cultural image chosen
    cipher_method   VARCHAR(20) NOT NULL DEFAULT '',
                    -- 'caesar'/'vigenere'/'morse'/'kotak'
    cipher_key      VARCHAR(100) NOT NULL DEFAULT '',
                    -- encryption key used (stored encrypted)
    flag_found      BOOLEAN NOT NULL DEFAULT FALSE,
    flag_found_at   TIMESTAMPTZ,
    flag_found_by   BIGINT REFERENCES teams(id),
    patch_completed BOOLEAN NOT NULL DEFAULT FALSE,
    patch_time_sec  INT,
    score           INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(ctf_room_id, team_id)
);

-- Attack log: AI conversations during attack phase
CREATE TABLE IF NOT EXISTS ctf_attack_logs (
    id              BIGSERIAL PRIMARY KEY,
    ctf_room_id     BIGINT NOT NULL REFERENCES ctf_rooms(id),
    attacking_team_id BIGINT NOT NULL REFERENCES teams(id),
    user_id         BIGINT NOT NULL REFERENCES users(id),
    prompt          TEXT NOT NULL,
    ai_response     TEXT NOT NULL,
    tokens_used     INT NOT NULL DEFAULT 1,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Patching challenges
CREATE TABLE IF NOT EXISTS ctf_patch_challenges (
    id              BIGSERIAL PRIMARY KEY,
    ctf_room_id     BIGINT NOT NULL REFERENCES ctf_rooms(id),
    team_id         BIGINT NOT NULL REFERENCES teams(id),
    challenge_type  VARCHAR(20) NOT NULL,
                    -- 'logic'/'cipher'/'binary'
    difficulty      VARCHAR(10) NOT NULL,
                    -- 'easy'/'medium'/'hard'
    question        TEXT NOT NULL,
    correct_answer  VARCHAR(200) NOT NULL,
    user_answer     VARCHAR(200),
    solved          BOOLEAN NOT NULL DEFAULT FALSE,
    solved_at       TIMESTAMPTZ,
    time_taken_sec  INT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_ctf_rooms_room_id ON ctf_rooms(room_id);
CREATE INDEX IF NOT EXISTS idx_ctf_teams_ctf_room ON ctf_teams(ctf_room_id);
CREATE INDEX IF NOT EXISTS idx_ctf_attack_logs_room ON ctf_attack_logs(ctf_room_id);
