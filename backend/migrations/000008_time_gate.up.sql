ALTER TABLE users 
ADD COLUMN IF NOT EXISTS first_active_date DATE;

UPDATE users SET first_active_date = created_at::DATE 
WHERE first_active_date IS NULL;
