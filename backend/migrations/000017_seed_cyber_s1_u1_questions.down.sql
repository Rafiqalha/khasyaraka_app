-- Hapus 50 soal Cyber Scout Bagian 1 Unit 1
-- Balikkan total_questions dan min_correct ke 0

UPDATE training_levels SET total_questions = 0, min_correct = 0
WHERE id IN (
    'cyber_s1_u1_l1','cyber_s1_u1_l2','cyber_s1_u1_l3','cyber_s1_u1_l4','cyber_s1_u1_l5',
    'cyber_s1_u1_l6','cyber_s1_u1_l7','cyber_s1_u1_l8','cyber_s1_u1_l9','cyber_s1_u1_l10'
);

DELETE FROM training_questions WHERE level_id IN (
    'cyber_s1_u1_l1','cyber_s1_u1_l2','cyber_s1_u1_l3','cyber_s1_u1_l4','cyber_s1_u1_l5',
    'cyber_s1_u1_l6','cyber_s1_u1_l7','cyber_s1_u1_l8','cyber_s1_u1_l9','cyber_s1_u1_l10'
);
