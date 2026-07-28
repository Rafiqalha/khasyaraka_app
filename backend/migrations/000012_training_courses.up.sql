CREATE TABLE IF NOT EXISTS training_courses (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    icon VARCHAR(50) NOT NULL DEFAULT 'security',
    ord INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE training_sections ADD COLUMN IF NOT EXISTS course_id VARCHAR(50) REFERENCES training_courses(id);
