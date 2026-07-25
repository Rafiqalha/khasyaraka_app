ALTER TABLE runtime_sessions DROP CONSTRAINT IF EXISTS fk_enrollment;
ALTER TABLE runtime_sessions DROP COLUMN IF EXISTS enrollment_id;
