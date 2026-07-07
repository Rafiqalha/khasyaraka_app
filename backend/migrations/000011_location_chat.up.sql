-- Add location to users
ALTER TABLE users
ADD COLUMN IF NOT EXISTS kecamatan_id VARCHAR(20),
ADD COLUMN IF NOT EXISTS kabupaten_id VARCHAR(20),
ADD COLUMN IF NOT EXISTS provinsi_id VARCHAR(20),
ADD COLUMN IF NOT EXISTS location_set BOOLEAN DEFAULT FALSE;

-- Chat rooms (auto-created per wilayah)
CREATE TABLE chat_rooms (
    id            BIGSERIAL PRIMARY KEY,
    room_type     VARCHAR(20) NOT NULL,
                  -- 'kecamatan'/'kabupaten'
                  -- 'provinsi'/'nasional'
    wilayah_id    VARCHAR(20),
                  -- NULL for nasional
                  -- kecamatan_id/kabupaten_id/provinsi_id
    name          VARCHAR(200) NOT NULL,
    member_count  INT NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(room_type, wilayah_id)
);

-- Insert nasional room immediately
INSERT INTO chat_rooms (room_type, wilayah_id, name)
VALUES ('nasional', NULL, 'Pramuka Indonesia 🇮🇩') ON CONFLICT DO NOTHING;

-- Messages
CREATE TABLE chat_messages_new (
    id          BIGSERIAL PRIMARY KEY,
    room_id     BIGINT NOT NULL REFERENCES chat_rooms(id)
                ON DELETE CASCADE,
    user_id     BIGINT NOT NULL REFERENCES users(id),
    content     TEXT NOT NULL,
    msg_type    VARCHAR(20) DEFAULT 'text',
                -- 'text'/'achievement'/'system'
    is_flagged  BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_chat_messages_room_created 
    ON chat_messages_new(room_id, created_at DESC);
CREATE INDEX idx_chat_messages_user 
    ON chat_messages_new(user_id);
CREATE INDEX idx_users_location 
    ON users(provinsi_id, kabupaten_id, kecamatan_id);

-- Drop old chat messages table if it exists
DROP TABLE IF EXISTS chat_messages;

-- Rename new table
ALTER TABLE chat_messages_new RENAME TO chat_messages;
