-- SEED INTERACTIVE DUOLINGO-STYLE QUESTIONS FOR TALI TEMALI
-- This script inserts 5 problem-solving questions into tali_u1_l1

-- 1. Multiple Choice (Problem Solving)
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) 
VALUES (
    'tali_u1_l1_q1', 
    'tali_u1_l1', 
    'multiple_choice', 
    'Tendamu hampir roboh ditiup angin kencang! Kamu harus segera mengikatkan tali tenda ke tiang pasak dengan ikatan yang kuat menjerat tapi mudah dilepaskan nanti. Simpul apa yang akan menyelamatkanmu?', 
    '{"options": ["Simpul Pangkal", "Simpul Mati", "Simpul Anyam", "Simpul Jangkar"], "correct_answer": "Simpul Pangkal"}', 
    2, 
    1
) ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- 2. Sorting (Process/Steps)
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) 
VALUES (
    'tali_u1_l1_q2', 
    'tali_u1_l1', 
    'sorting', 
    'Kamu menemukan dua utas tali berukuran SAMA saat tersesat di hutan. Susun urutan membuat ''Simpul Mati'' agar dua tali pendek ini bisa disambung dengan kuat!', 
    '{"items": ["Siapkan ujung kedua tali", "Silangkan ujung kiri di atas kanan", "Silangkan ujung kanan di atas kiri", "Tarik kedua ujung hingga erat"], "correct_order": ["Siapkan ujung kedua tali", "Silangkan ujung kiri di atas kanan", "Silangkan ujung kanan di atas kiri", "Tarik kedua ujung hingga erat"]}', 
    3, 
    2
) ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- 3. Matching (Concepts)
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) 
VALUES (
    'tali_u1_l1_q3', 
    'tali_u1_l1', 
    'matching', 
    'Berpikir cepat! Cocokkan nama simpul di sebelah kiri dengan fungsi darurat yang tepat di sebelah kanan!', 
    '{"pairs": [{"left": "Simpul Mati", "right": "Menyambung 2 tali sama besar"}, {"left": "Simpul Pangkal", "right": "Mengikat erat tiang/kayu"}, {"left": "Simpul Tiang", "right": "Mengikat leher hewan peliharaan"}, {"left": "Simpul Anyam", "right": "Menyambung 2 tali beda ukuran"}]}', 
    4, 
    3
) ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- 4. Arrange Words (Decoding)
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) 
VALUES (
    'tali_u1_l1_q4', 
    'tali_u1_l1', 
    'arrange_words', 
    'Buku catatan pandumu robek! Susun kembali potongan kertas ini untuk mengetahui fungsi utama dari Simpul Anyam.', 
    '{"words": ["untuk", "menyambung", "dua", "utas", "tali", "yang", "tidak", "sama", "besar"], "correct_order": ["untuk", "menyambung", "dua", "utas", "tali", "yang", "tidak", "sama", "besar"]}', 
    3, 
    4
) ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- 5. Input / Fill in the blank (Riddle)
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) 
VALUES (
    'tali_u1_l1_q5', 
    'tali_u1_l1', 
    'input', 
    'Pecahkan teka-teki ini: "Aku sangat berguna untuk mengawali dan mengakhiri sebuah ikatan pada tongkat pionering. Siapakah aku?" (Ketik satu kata saja)', 
    '{"correct_answer": "Pangkal"}', 
    3, 
    5
) ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;
