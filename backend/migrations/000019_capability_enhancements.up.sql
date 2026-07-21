-- Menambahkan skema evaluasi dan freshness_score 
ALTER TABLE learner_capabilities 
ADD COLUMN evaluation_version VARCHAR(20) DEFAULT 'v1.0',
ADD COLUMN freshness_score DECIMAL(3,2) DEFAULT 1.00;
