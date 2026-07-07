-- 1. Room kompetisi
CREATE TABLE arena_rooms (
    id               BIGSERIAL PRIMARY KEY,
    code             VARCHAR(8) UNIQUE NOT NULL,
    host_user_id     BIGINT NOT NULL REFERENCES users(id),
    title            VARCHAR(100) NOT NULL DEFAULT 'Arena Cyber-Scout',
    status           VARCHAR(20) NOT NULL DEFAULT 'waiting',
    max_teams        INT NOT NULL DEFAULT 5,
    players_per_team INT NOT NULL DEFAULT 5,
    total_questions  INT NOT NULL DEFAULT 10,
    q_time_secs      INT NOT NULL DEFAULT 30,
    current_q_index  INT NOT NULL DEFAULT -1,
    q_started_at     TIMESTAMPTZ,
    started_at       TIMESTAMPTZ,
    finished_at      TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_arena_rooms_code ON arena_rooms(code);
CREATE INDEX idx_arena_rooms_status ON arena_rooms(status);

-- 2. Tim di dalam room
CREATE TABLE arena_teams (
    id              BIGSERIAL PRIMARY KEY,
    room_id         BIGINT NOT NULL REFERENCES arena_rooms(id) ON DELETE CASCADE,
    name            VARCHAR(100) NOT NULL,
    slot            INT NOT NULL,
    captain_user_id BIGINT NOT NULL REFERENCES users(id),
    total_score     INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(room_id, slot)
);

-- 3. Pemain di dalam tim
CREATE TABLE arena_players (
    id         BIGSERIAL PRIMARY KEY,
    team_id    BIGINT NOT NULL REFERENCES arena_teams(id) ON DELETE CASCADE,
    room_id    BIGINT NOT NULL REFERENCES arena_rooms(id) ON DELETE CASCADE,
    user_id    BIGINT NOT NULL REFERENCES users(id),
    is_captain BOOLEAN NOT NULL DEFAULT false,
    score      INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(room_id, user_id)
);

-- 4. Soal per room (di-generate saat room dibuat)
CREATE TABLE arena_questions (
    id             BIGSERIAL PRIMARY KEY,
    room_id        BIGINT NOT NULL REFERENCES arena_rooms(id) ON DELETE CASCADE,
    q_order        INT NOT NULL,
    question_text  TEXT NOT NULL,
    question_type  VARCHAR(30) NOT NULL,
    payload        JSONB NOT NULL,
    correct_answer TEXT NOT NULL,
    points         INT NOT NULL DEFAULT 100,
    UNIQUE(room_id, q_order)
);

-- 5. Jawaban pemain
CREATE TABLE arena_answers (
    id            BIGSERIAL PRIMARY KEY,
    room_id       BIGINT NOT NULL REFERENCES arena_rooms(id) ON DELETE CASCADE,
    question_id   BIGINT NOT NULL REFERENCES arena_questions(id),
    team_id       BIGINT NOT NULL REFERENCES arena_teams(id),
    player_id     BIGINT NOT NULL REFERENCES arena_players(id),
    answer        TEXT NOT NULL,
    is_correct    BOOLEAN NOT NULL DEFAULT false,
    time_taken_ms INT NOT NULL DEFAULT 0,
    points_earned INT NOT NULL DEFAULT 0,
    answered_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(question_id, player_id)
);

-- 6. Chat Global (untuk share kode room)
CREATE TABLE chat_messages (
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT NOT NULL REFERENCES users(id),
    message    TEXT NOT NULL,
    room_code  VARCHAR(8),
    msg_type   VARCHAR(20) NOT NULL DEFAULT 'text',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_chat_messages_created ON chat_messages(created_at DESC);
