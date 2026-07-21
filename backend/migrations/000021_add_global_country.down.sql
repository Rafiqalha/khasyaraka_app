DROP INDEX IF EXISTS idx_users_country_id;

ALTER TABLE users DROP COLUMN IF EXISTS country_id;

DROP TABLE IF EXISTS countries;
