ALTER TABLE training_questions ADD COLUMN IF NOT EXISTS source VARCHAR(20) NOT NULL DEFAULT 'static';
ALTER TABLE training_questions ADD COLUMN IF NOT EXISTS difficulty_level INT NOT NULL DEFAULT 3;
ALTER TABLE training_questions ADD COLUMN IF NOT EXISTS generated_at TIMESTAMP;
ALTER TABLE training_questions ADD COLUMN IF NOT EXISTS source_url VARCHAR(500);

CREATE INDEX IF NOT EXISTS idx_questions_source ON training_questions(source);
CREATE INDEX IF NOT EXISTS idx_questions_difficulty ON training_questions(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_questions_generated ON training_questions(generated_at DESC);

UPDATE training_questions SET source = 'static' WHERE source = 'static';
