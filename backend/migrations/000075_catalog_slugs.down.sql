ALTER TABLE learning_goals 
DROP CONSTRAINT IF EXISTS unique_learning_goal_slug,
DROP COLUMN IF EXISTS slug,
DROP COLUMN IF EXISTS status;
