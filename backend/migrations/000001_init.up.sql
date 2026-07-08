CREATE TABLE users (
    id              BIGSERIAL PRIMARY KEY,
    full_name       VARCHAR(255),
    email           VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    picture_url     VARCHAR(500),
    total_xp        INTEGER NOT NULL DEFAULT 0,
    hack_level      VARCHAR(50) DEFAULT 'Script Kiddie',
    decrypted_count INTEGER NOT NULL DEFAULT 0,
    streak          INTEGER NOT NULL DEFAULT 0,
    longest_streak  INTEGER NOT NULL DEFAULT 0,
    hearts          INTEGER NOT NULL DEFAULT 5,
    last_active_date DATE,
    timezone        VARCHAR(50) NOT NULL DEFAULT 'Asia/Jakarta',
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    is_superuser    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_full_name ON users(full_name);

-- Training
CREATE TABLE training_sections (
    id          VARCHAR(50) PRIMARY KEY,
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    tier        VARCHAR(20) NOT NULL DEFAULT 'free',
    ord         INTEGER NOT NULL DEFAULT 1,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE training_units (
    id           VARCHAR(50) PRIMARY KEY,
    section_id   VARCHAR(50) NOT NULL REFERENCES training_sections(id),
    title        VARCHAR(200) NOT NULL,
    description  TEXT,
    ord          INTEGER NOT NULL DEFAULT 1,
    total_levels INTEGER NOT NULL DEFAULT 0,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE training_levels (
    id              VARCHAR(50) PRIMARY KEY,
    unit_id         VARCHAR(50) NOT NULL REFERENCES training_units(id),
    level_number    INTEGER NOT NULL,
    difficulty      VARCHAR(20) NOT NULL DEFAULT 'easy',
    total_questions INTEGER NOT NULL DEFAULT 5,
    min_correct     INTEGER NOT NULL DEFAULT 4,
    xp_reward       INTEGER NOT NULL DEFAULT 10,
    unlock_rule     JSONB,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE training_questions (
    id        VARCHAR(50) PRIMARY KEY,
    level_id  VARCHAR(50) NOT NULL REFERENCES training_levels(id),
    type      VARCHAR(30) NOT NULL,
    question  TEXT NOT NULL,
    payload   JSONB NOT NULL,
    xp        INTEGER NOT NULL DEFAULT 2,
    ord       INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE user_progress (
    id                BIGSERIAL PRIMARY KEY,
    user_id           INTEGER NOT NULL REFERENCES users(id),
    level_id          VARCHAR(50) NOT NULL REFERENCES training_levels(id),
    status            VARCHAR(20) NOT NULL DEFAULT 'LOCKED',
    score             INTEGER NOT NULL DEFAULT 0,
    total_questions   INTEGER NOT NULL DEFAULT 0,
    correct_answers   INTEGER NOT NULL DEFAULT 0,
    xp_earned         INTEGER NOT NULL DEFAULT 0,
    time_spent_seconds INTEGER NOT NULL DEFAULT 0,
    completed_at      TIMESTAMP,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_level_id ON user_progress(level_id);

-- Legacy training paths
CREATE TABLE pradigi_training_paths (
    id          UUID PRIMARY KEY,
    title       VARCHAR(100) NOT NULL,
    description TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE
);

-- Cyber / Sandi
CREATE TABLE cyber_modules (
    id              VARCHAR(50) PRIMARY KEY,
    title           VARCHAR(200) NOT NULL,
    original_title  VARCHAR(200) NOT NULL,
    difficulty      INTEGER NOT NULL DEFAULT 1,
    min_read_seconds INTEGER NOT NULL DEFAULT 20,
    intel_content   JSONB NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE cyber_challenges (
    id               VARCHAR(50) PRIMARY KEY,
    module_id        VARCHAR(50) NOT NULL REFERENCES cyber_modules(id),
    level            INTEGER NOT NULL DEFAULT 1,
    category         VARCHAR(50) NOT NULL,
    difficulty       INTEGER NOT NULL DEFAULT 1,
    encrypted_data   JSONB NOT NULL,
    decrypted_answer VARCHAR(200) NOT NULL,
    xp_reward        INTEGER NOT NULL DEFAULT 5,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cyber_challenges_category ON cyber_challenges(category);
CREATE INDEX idx_cyber_challenges_module_id ON cyber_challenges(module_id);

CREATE TABLE cyber_level_progress (
    id           BIGSERIAL PRIMARY KEY,
    user_id      INTEGER NOT NULL REFERENCES users(id),
    module_id    VARCHAR(50) NOT NULL REFERENCES cyber_modules(id),
    level        INTEGER NOT NULL DEFAULT 1,
    stars        INTEGER NOT NULL DEFAULT 0,
    score        INTEGER NOT NULL DEFAULT 0,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, module_id, level)
);

CREATE INDEX idx_cyber_level_progress_user_id ON cyber_level_progress(user_id);
CREATE INDEX idx_cyber_level_progress_module_id ON cyber_level_progress(module_id);

CREATE TABLE user_solved_challenges (
    id           BIGSERIAL PRIMARY KEY,
    user_id      INTEGER NOT NULL REFERENCES users(id),
    challenge_id VARCHAR(50) NOT NULL REFERENCES cyber_challenges(id),
    solved_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, challenge_id)
);

CREATE INDEX idx_user_solved_challenges_user_id ON user_solved_challenges(user_id);
CREATE INDEX idx_user_solved_challenges_challenge_id ON user_solved_challenges(challenge_id);

-- Sandi Pramuka (for Encrypt/Decrypt tools)
CREATE TABLE sandi_types (
    id          BIGSERIAL PRIMARY KEY,
    codename    VARCHAR(50) UNIQUE NOT NULL,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    difficulty  INTEGER NOT NULL DEFAULT 1,
    category    VARCHAR(50) NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sandi_types_codename ON sandi_types(codename);

CREATE TABLE sandi_questions (
    id             BIGSERIAL PRIMARY KEY,
    sandi_id       INTEGER NOT NULL REFERENCES sandi_types(id),
    question_text  TEXT NOT NULL,
    encrypted_text TEXT NOT NULL,
    correct_answer VARCHAR(500) NOT NULL,
    hint           TEXT,
    difficulty     INTEGER NOT NULL DEFAULT 1,
    xp_reward      INTEGER NOT NULL DEFAULT 10,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sandi_questions_sandi_id ON sandi_questions(sandi_id);

CREATE TABLE encryption_logs (
    id             BIGSERIAL PRIMARY KEY,
    user_id        INTEGER NOT NULL REFERENCES users(id),
    sandi_id       INTEGER NOT NULL REFERENCES sandi_types(id),
    input_hash     VARCHAR(64) NOT NULL,
    operation_mode VARCHAR(20) NOT NULL,
    timestamp      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_encryption_logs_user_id ON encryption_logs(user_id);
CREATE INDEX idx_encryption_logs_input_hash ON encryption_logs(input_hash);
CREATE INDEX idx_encryption_logs_timestamp ON encryption_logs(timestamp);

-- SKU (Syarat Kecakapan Umum)
CREATE TABLE sku_points (
    id          VARCHAR(50) PRIMARY KEY,
    level       VARCHAR(20) NOT NULL,
    number      INTEGER NOT NULL,
    title       VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category    VARCHAR(100) NOT NULL,
    quiz_content JSONB NOT NULL
);

CREATE TABLE sku_progress (
    user_id      INTEGER NOT NULL REFERENCES users(id),
    sku_point_id VARCHAR(50) NOT NULL REFERENCES sku_points(id),
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    score        INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY(user_id, sku_point_id)
);

-- Special Missions (SKK)
CREATE TABLE pradigi_special_missions (
    id              BIGSERIAL PRIMARY KEY,
    mission_title   VARCHAR(200) NOT NULL,
    level_category  VARCHAR(50) NOT NULL,
    badge_image_url VARCHAR(500),
    is_premium      BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_pradigi_special_missions_id ON pradigi_special_missions(id);

CREATE TABLE pradigi_mission_tasks (
    id             BIGSERIAL PRIMARY KEY,
    mission_id     INTEGER NOT NULL REFERENCES pradigi_special_missions(id),
    type           VARCHAR(30) NOT NULL,
    question       TEXT NOT NULL,
    options        JSONB,
    correct_index  INTEGER,
    correct_text   TEXT,
    explanation    TEXT
);

CREATE INDEX idx_pradigi_mission_tasks_id ON pradigi_mission_tasks(id);

-- Survival Mastery
CREATE TYPE tool_type AS ENUM ('compass', 'clinometer', 'pedometer', 'morse', 'leveler', 'gps_tracker');

CREATE TABLE survival_mastery (
    id                    BIGSERIAL PRIMARY KEY,
    user_id               INTEGER NOT NULL REFERENCES users(id),
    tool_type             tool_type NOT NULL,
    current_xp            INTEGER NOT NULL DEFAULT 0,
    current_level         INTEGER NOT NULL DEFAULT 1,
    total_actions         INTEGER NOT NULL DEFAULT 0,
    highest_streak        INTEGER NOT NULL DEFAULT 0,
    max_altitude          DOUBLE PRECISION NOT NULL DEFAULT 0,
    total_distance_tracked DOUBLE PRECISION NOT NULL DEFAULT 0,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Subscriptions
CREATE TABLE subscriptions (
    id                      BIGSERIAL PRIMARY KEY,
    user_id                 INTEGER NOT NULL REFERENCES users(id),
    tier                    VARCHAR(50) NOT NULL DEFAULT 'free',
    status                  VARCHAR(50) NOT NULL DEFAULT 'active',
    start_date              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_date                TIMESTAMPTZ,
    payment_reference       VARCHAR(255),
    billing_provider        VARCHAR(100),
    provider_subscription_id VARCHAR(255),
    auto_renew              BOOLEAN NOT NULL DEFAULT FALSE,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);

-- TKK (Tanda Kecakapan Khusus)
CREATE TYPE tkk_level AS ENUM ('purwa', 'madya', 'utama');

CREATE TABLE user_tkk (
    id           BIGSERIAL PRIMARY KEY,
    user_id      INTEGER NOT NULL REFERENCES users(id),
    tkk_slug     VARCHAR(255) NOT NULL,
    level        tkk_level NOT NULL,
    attained_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, tkk_slug, level)
);

CREATE INDEX idx_user_tkk_user_id ON user_tkk(user_id);
CREATE INDEX idx_user_tkk_tkk_slug ON user_tkk(tkk_slug);
