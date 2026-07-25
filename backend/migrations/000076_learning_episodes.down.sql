DROP INDEX IF EXISTS idx_snapshots_episode;
DROP INDEX IF EXISTS idx_events_episode;
DROP INDEX IF EXISTS idx_episodes_user;

DROP TABLE IF EXISTS episode_reflections CASCADE;
DROP TABLE IF EXISTS episode_evaluations CASCADE;
DROP TABLE IF EXISTS episode_snapshots CASCADE;
DROP TABLE IF EXISTS episode_events CASCADE;
DROP TABLE IF EXISTS learning_episodes CASCADE;
