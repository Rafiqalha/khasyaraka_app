CREATE TABLE training_courses (
    id          VARCHAR(50) PRIMARY KEY,
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    icon        VARCHAR(50) NOT NULL DEFAULT 'explore',
    ord         INTEGER NOT NULL DEFAULT 1,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add course_id to sections
ALTER TABLE training_sections ADD COLUMN course_id VARCHAR(50);

-- Seed initial courses
INSERT INTO training_courses (id, title, description, icon, ord) VALUES 
('puk', 'Pengetahuan Umum', 'Pahami dasar-dasar kepramukaan.', 'school', 1),
('ppgd', 'Pertolongan Pertama', 'P3K dan pertolongan darurat.', 'local_hospital', 2),
('nav', 'Navigasi', 'Membaca peta, kompas, dan alam.', 'explore', 3),
('tali', 'Tali Temali', 'Simpul dan pionering.', 'workspaces', 4),
('sandi', 'Sandi & Isyarat', 'Sandi morse, semaphore, dll.', 'vpn_key', 5)
ON CONFLICT (id) DO NOTHING;

-- Map existing sections to courses
UPDATE training_sections SET course_id = 'puk' WHERE id = 'puk';
UPDATE training_sections SET course_id = 'ppgd' WHERE id = 'ppgd';
UPDATE training_sections SET course_id = 'nav' WHERE id = 'nav';
UPDATE training_sections SET course_id = 'tali' WHERE id = 'tali';
UPDATE training_sections SET course_id = 'sandi' WHERE id = 'sandi';

-- Make course_id NOT NULL after seeding
ALTER TABLE training_sections ALTER COLUMN course_id SET NOT NULL;

-- Add foreign key
ALTER TABLE training_sections ADD CONSTRAINT fk_training_sections_course 
FOREIGN KEY (course_id) REFERENCES training_courses(id) ON DELETE CASCADE;

-- Rename sections to be generic "Bagian X" since the course provides the context
UPDATE training_sections SET title = 'Bagian 1: Dasar' WHERE id = 'puk';
UPDATE training_sections SET title = 'Bagian 1: Dasar' WHERE id = 'ppgd';
UPDATE training_sections SET title = 'Bagian 1: Dasar' WHERE id = 'nav';
UPDATE training_sections SET title = 'Bagian 1: Dasar' WHERE id = 'tali';
UPDATE training_sections SET title = 'Bagian 1: Dasar' WHERE id = 'sandi';

-- Create index for faster querying
CREATE INDEX idx_training_sections_course ON training_sections(course_id);