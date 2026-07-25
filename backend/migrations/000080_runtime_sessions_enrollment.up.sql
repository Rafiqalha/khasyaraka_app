ALTER TABLE runtime_sessions ADD COLUMN IF NOT EXISTS enrollment_id VARCHAR(50);
-- In a real scenario we'd add REFERENCES learning_enrollments(id), but we need to handle existing data if any
ALTER TABLE runtime_sessions ADD CONSTRAINT fk_enrollment FOREIGN KEY (enrollment_id) REFERENCES learning_enrollments(id) ON DELETE CASCADE;
