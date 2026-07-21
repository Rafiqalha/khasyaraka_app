CREATE TABLE IF NOT EXISTS countries (
    id   VARCHAR(2) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(3) NOT NULL
);

INSERT INTO countries (id, name, code) VALUES
  ('ID', 'Indonesia', 'IDN'),
  ('SG', 'Singapore', 'SGP'),
  ('MY', 'Malaysia', 'MYS'),
  ('TH', 'Thailand', 'THA'),
  ('PH', 'Philippines', 'PHL'),
  ('VN', 'Vietnam', 'VNM'),
  ('US', 'United States', 'USA'),
  ('GB', 'United Kingdom', 'GBR')
ON CONFLICT (id) DO NOTHING;

ALTER TABLE users ADD COLUMN IF NOT EXISTS country_id VARCHAR(2) DEFAULT 'ID' REFERENCES countries(id);

CREATE INDEX IF NOT EXISTS idx_users_country_id ON users(country_id);

UPDATE users SET country_id = 'ID' WHERE country_id IS NULL;
