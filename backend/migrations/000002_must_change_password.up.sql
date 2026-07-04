ALTER TABLE users ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN NOT NULL DEFAULT FALSE;
-- Set all existing users to must change password (mass reset was done with pradigi05)
UPDATE users SET must_change_password = TRUE;
