-- Seed missing mock goals for the MVP interview flow
INSERT INTO learning_goals (id, specialization_id, title, slug, status, description, learning_objective) VALUES
('goal_ai_engineer', 'soc-analyst', 'AI Engineer', 'ai-engineer', 'ACTIVE', 'Mock AI Engineer Goal', 'Master AI Engineering'),
('goal_startup_founder', 'soc-analyst', 'Startup Founder', 'startup-founder', 'ACTIVE', 'Mock Startup Founder Goal', 'Build a successful startup'),
('goal_backend_engineer', 'soc-analyst', 'Backend Engineer', 'backend-engineer', 'ACTIVE', 'Mock Backend Engineer Goal', 'Master Backend Systems')
ON CONFLICT (slug) DO NOTHING;
