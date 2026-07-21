CREATE TABLE IF NOT EXISTS game_rooms (
    id              BIGSERIAL PRIMARY KEY,
    code            VARCHAR(10) UNIQUE NOT NULL,
    host_user_id    BIGINT NOT NULL REFERENCES users(id),
    mode            VARCHAR(20) NOT NULL DEFAULT '',
    status          VARCHAR(20) NOT NULL DEFAULT 'lobby',
    team_a_attacker BIGINT REFERENCES users(id),
    team_a_defender BIGINT REFERENCES users(id),
    team_b_attacker BIGINT REFERENCES users(id),
    team_b_defender BIGINT REFERENCES users(id),
    player_count    INT NOT NULL DEFAULT 0,
    current_round   INT NOT NULL DEFAULT 0,
    max_rounds      INT NOT NULL DEFAULT 5,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    started_at      TIMESTAMPTZ,
    finished_at     TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS game_rounds (
    id              BIGSERIAL PRIMARY KEY,
    room_id         BIGINT NOT NULL REFERENCES game_rooms(id),
    round_num       INT NOT NULL,
    attacker_team   INT NOT NULL DEFAULT 1,
    scenario        TEXT NOT NULL DEFAULT '',
    status          VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(room_id, round_num)
);

CREATE TABLE IF NOT EXISTS game_actions (
    id              BIGSERIAL PRIMARY KEY,
    round_id        BIGINT NOT NULL REFERENCES game_rounds(id),
    user_id         BIGINT NOT NULL REFERENCES users(id),
    role            VARCHAR(20) NOT NULL,
    input           TEXT NOT NULL DEFAULT '',
    output          TEXT NOT NULL DEFAULT '',
    score_change    INT NOT NULL DEFAULT 0,
    ethical_change  INT NOT NULL DEFAULT 0,
    time_taken_secs INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
