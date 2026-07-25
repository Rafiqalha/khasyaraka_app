-- Revert Soal Sandi Kotak Dasar (S1 U2)
UPDATE training_levels SET total_questions = 0, min_correct = 0
WHERE id IN (
    'cyber_s1_u2_l1','cyber_s1_u2_l2','cyber_s1_u2_l3','cyber_s1_u2_l4','cyber_s1_u2_l5',
    'cyber_s1_u2_l6','cyber_s1_u2_l7','cyber_s1_u2_l8','cyber_s1_u2_l9','cyber_s1_u2_l10'
);

DELETE FROM training_questions WHERE id IN (
    'cyber_s1_u2_l1_q1','cyber_s1_u2_l1_q2','cyber_s1_u2_l1_q3','cyber_s1_u2_l1_q4','cyber_s1_u2_l1_q5',
    'cyber_s1_u2_l2_q1','cyber_s1_u2_l2_q2','cyber_s1_u2_l2_q3','cyber_s1_u2_l2_q4','cyber_s1_u2_l2_q5',
    'cyber_s1_u2_l3_q1','cyber_s1_u2_l3_q2','cyber_s1_u2_l3_q3','cyber_s1_u2_l3_q4','cyber_s1_u2_l3_q5',
    'cyber_s1_u2_l4_q1','cyber_s1_u2_l4_q2','cyber_s1_u2_l4_q3','cyber_s1_u2_l4_q4','cyber_s1_u2_l4_q5',
    'cyber_s1_u2_l5_q1','cyber_s1_u2_l5_q2','cyber_s1_u2_l5_q3','cyber_s1_u2_l5_q4','cyber_s1_u2_l5_q5',
    'cyber_s1_u2_l6_q1','cyber_s1_u2_l6_q2','cyber_s1_u2_l6_q3','cyber_s1_u2_l6_q4','cyber_s1_u2_l6_q5',
    'cyber_s1_u2_l7_q1','cyber_s1_u2_l7_q2','cyber_s1_u2_l7_q3','cyber_s1_u2_l7_q4','cyber_s1_u2_l7_q5',
    'cyber_s1_u2_l8_q1','cyber_s1_u2_l8_q2','cyber_s1_u2_l8_q3','cyber_s1_u2_l8_q4','cyber_s1_u2_l8_q5',
    'cyber_s1_u2_l9_q1','cyber_s1_u2_l9_q2','cyber_s1_u2_l9_q3','cyber_s1_u2_l9_q4','cyber_s1_u2_l9_q5',
    'cyber_s1_u2_l10_q1','cyber_s1_u2_l10_q2','cyber_s1_u2_l10_q3','cyber_s1_u2_l10_q4','cyber_s1_u2_l10_q5'
);
