DROP INDEX IF EXISTS idx_questions_generated;
DROP INDEX IF EXISTS idx_questions_difficulty;
DROP INDEX IF EXISTS idx_questions_source;

ALTER TABLE training_questions DROP COLUMN IF EXISTS source_url;
ALTER TABLE training_questions DROP COLUMN IF EXISTS generated_at;
ALTER TABLE training_questions DROP COLUMN IF EXISTS difficulty_level;
ALTER TABLE training_questions DROP COLUMN IF EXISTS source;
