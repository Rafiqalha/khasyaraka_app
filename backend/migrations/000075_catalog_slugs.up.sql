ALTER TABLE learning_goals 
ADD COLUMN IF NOT EXISTS slug VARCHAR(100),
ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'ACTIVE';

-- Seed slug for the existing goal
UPDATE learning_goals 
SET slug = 'soc-analyst' 
WHERE id = 'cyber_soc_analyst';

-- Now that existing data is populated, add the unique constraint safely
ALTER TABLE learning_goals ADD CONSTRAINT unique_learning_goal_slug UNIQUE (slug);
