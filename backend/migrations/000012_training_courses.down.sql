-- Remove foreign key
ALTER TABLE training_sections DROP CONSTRAINT fk_training_sections_course;

-- Remove course_id column from sections
ALTER TABLE training_sections DROP COLUMN course_id;

-- Drop index
DROP INDEX idx_training_sections_course;

-- Drop table
DROP TABLE training_courses;
