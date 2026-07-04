-- REVERT INTERACTIVE DUOLINGO-STYLE QUESTIONS FOR TALI TEMALI

DELETE FROM training_questions WHERE id IN (
    'tali_u1_l1_q1',
    'tali_u1_l1_q2',
    'tali_u1_l1_q3',
    'tali_u1_l1_q4',
    'tali_u1_l1_q5'
);
