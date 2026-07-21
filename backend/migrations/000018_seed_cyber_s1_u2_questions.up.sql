-- Seed 50 Soal untuk Cyber Scout Bagian 1 Unit 2: "Sandi Kotak Dasar"
-- 10 level x 5 soal = 50 soal
-- Progresi: kenali bentuk kotak -> mapping huruf -> baca kode -> tulis kode -> kombinasi -> analisis -> challenge

UPDATE training_levels SET total_questions = 5, min_correct = 3
WHERE id IN (
    'cyber_s1_u2_l1','cyber_s1_u2_l2','cyber_s1_u2_l3','cyber_s1_u2_l4','cyber_s1_u2_l5',
    'cyber_s1_u2_l6','cyber_s1_u2_l7','cyber_s1_u2_l8','cyber_s1_u2_l9','cyber_s1_u2_l10'
);

-- LEVEL 1: Kenali bentuk dasar kotak
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l1_q1', 'cyber_s1_u2_l1', 'multiple_choice',
'Sandi Kotak adalah sandi yang menggunakan...',
'{"options":["Bentuk kotak dan titik","Titik dan garis","Bendera","Angka"],"correct_answer":"Bentuk kotak dan titik"}'::jsonb, 2, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l1_q2', 'cyber_s1_u2_l1', 'multiple_choice',
'Dalam Sandi Kotak 1, satu kotak tanpa titik mewakili... huruf.',
'{"options":["3","1","2","4"],"correct_answer":"3"}'::jsonb, 2, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l1_q3', 'cyber_s1_u2_l1', 'multiple_choice',
'Bentuk dasar Sandi Kotak terdiri dari...',
'{"options":["9 kotak (3x3)","4 kotak (2x2)","6 kotak (2x3)","12 kotak (3x4)"],"correct_answer":"9 kotak (3x3)"}'::jsonb, 2, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l1_q4', 'cyber_s1_u2_l1', 'matching',
'Cocokkan posisi kotak dengan jumlah titik!',
'{"pairs":[{"left":"Kotak tanpa titik","right":"Huruf A, B, C"},{"left":"Kotak 1 titik","right":"Huruf J, K, L"},{"left":"Kotak 2 titik","right":"Huruf S, T, U"}]}'::jsonb, 3, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l1_q5', 'cyber_s1_u2_l1', 'input',
'Sandi Kotak termasuk jenis sandi... (r, a, h, a, s, i, a)',
'{"correct_answer":"rahasia"}'::jsonb, 2, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- LEVEL 2: Mapping huruf ke kotak
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l2_q1', 'cyber_s1_u2_l2', 'matching',
'Cocokkan huruf dengan posisi kotaknya!',
'{"pairs":[{"left":"A","right":"Kotak kiri atas, tanpa titik"},{"left":"B","right":"Kotak tengah atas, tanpa titik"},{"left":"C","right":"Kotak kanan atas, tanpa titik"}]}'::jsonb, 3, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l2_q2', 'cyber_s1_u2_l2', 'multiple_choice',
'Huruf D berada di kotak mana dalam Sandi Kotak 1?',
'{"options":["Kiri tengah, tanpa titik","Kanan atas, tanpa titik","Kiri bawah, 1 titik","Tengah, 2 titik"],"correct_answer":"Kiri tengah, tanpa titik"}'::jsonb, 2, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l2_q3', 'cyber_s1_u2_l2', 'input',
'Dalam Sandi Kotak 1, huruf A berada di kotak nomor berapa? (Ketik 1-9)',
'{"correct_answer":"1"}'::jsonb, 2, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l2_q4', 'cyber_s1_u2_l2', 'multiple_choice',
'Huruf M menggunakan kotak dengan...',
'{"options":["1 titik, tengah","2 titik, kiri","Tanpa titik, kanan","1 titik, kiri"],"correct_answer":"1 titik, tengah"}'::jsonb, 2, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l2_q5', 'cyber_s1_u2_l2', 'sorting',
'Urutkan huruf berdasarkan posisi kotak dari kiri ke kanan, atas ke bawah!',
'{"items":["A","D","G","J","M","P","S","V","Y"],"correct_order":["A","D","G","J","M","P","S","V","Y"]}'::jsonb, 4, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- LEVEL 3: Baca kode kotak (huruf tunggal)
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l3_q1', 'cyber_s1_u2_l3', 'multiple_choice',
'Dalam Sandi Kotak 1, kotak kiri atas tanpa titik adalah huruf...',
'{"options":["A","B","C","D"],"correct_answer":"A"}'::jsonb, 2, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l3_q2', 'cyber_s1_u2_l3', 'matching',
'Cocokkan deskripsi kotak dengan huruf yang benar!',
'{"pairs":[{"left":"Kotak kanan atas, tanpa titik","right":"C"},{"left":"Kotak kiri tengah, 1 titik","right":"J"},{"left":"Kotak kanan bawah, 2 titik","right":"Z"}]}'::jsonb, 3, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l3_q3', 'cyber_s1_u2_l3', 'input',
'Kotak kiri bawah dengan 1 titik adalah huruf...',
'{"correct_answer":"P"}'::jsonb, 2, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l3_q4', 'cyber_s1_u2_l3', 'multiple_choice',
'Kotak tengah, 2 titik adalah huruf...',
'{"options":["W","X","Y","V"],"correct_answer":"W"}'::jsonb, 2, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l3_q5', 'cyber_s1_u2_l3', 'input',
'Kotak kiri atas dengan 2 titik adalah huruf...',
'{"correct_answer":"S"}'::jsonb, 2, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- LEVEL 4: Baca kata pendek
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l4_q1', 'cyber_s1_u2_l4', 'multiple_choice',
'Jika kotak A=tanpa titik kiri atas, B=tanpa titik tengah atas, C=tanpa titik kanan atas, maka sandi kotak "A-C" adalah...',
'{"options":["AC","CA","AB","BC"],"correct_answer":"AC"}'::jsonb, 3, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l4_q2', 'cyber_s1_u2_l4', 'arrange_words',
'Urutkan huruf berdasarkan gambar kotak berikut: kiri-atas, tengah-atas, kanan-atas (semua tanpa titik)',
'{"words":["A","B","C"],"correct_order":["A","B","C"]}'::jsonb, 3, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l4_q3', 'cyber_s1_u2_l4', 'multiple_choice',
'Kotak kiri-atas tanpa titik lalu kotak kanan-bawah 2 titik menghasilkan huruf...',
'{"options":["A dan Z","A dan Y","B dan Z","C dan Y"],"correct_answer":"A dan Z"}'::jsonb, 3, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l4_q4', 'cyber_s1_u2_l4', 'matching',
'Cocokkan kombinasi kotak dengan kata 2 huruf yang terbentuk!',
'{"pairs":[{"left":"A lalu P","right":"AP"},{"left":"S lalu I","right":"SI"},{"left":"J lalu O","right":"JO"}]}'::jsonb, 4, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l4_q5', 'cyber_s1_u2_l4', 'input',
'Kotak kiri-atas tanpa titik diikuti kotak kiri-tengah tanpa titik = huruf apa? (2 huruf kapital)',
'{"correct_answer":"AD"}'::jsonb, 3, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- LEVEL 5: Baca kata 3-4 huruf
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l5_q1', 'cyber_s1_u2_l5', 'packet_sweeper',
'Geser ke KANAN jika huruf-huruf ini BISA ditulis dalam Sandi Kotak 1, ke KIRI jika TIDAK!',
'{"packets":[{"protocol":"KOTAK1","source":"Pramuka","dest":"Regu","method":"Sandi Kotak","payload_preview":"A, B, C","is_malicious":false},{"protocol":"KOTAK1","source":"Pramuka","dest":"Regu","method":"Sandi Kotak","payload_preview":"X, Y, Z","is_malicious":false},{"protocol":"BUKAN","source":"Luar","dest":"?","method":"?","payload_preview":"Angka 1, 2, 3","is_malicious":true},{"protocol":"KOTAK1","source":"Pramuka","dest":"Regu","method":"Sandi Kotak","payload_preview":"!, @, #","is_malicious":true}]}'::jsonb, 5, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l5_q2', 'cyber_s1_u2_l5', 'multiple_choice',
'Kata "BUKU" dalam Sandi Kotak 1 terdiri dari huruf: B=?, U=?, K=?, U=?. Huruf K berada di kotak...',
'{"options":["Kiri tengah, 1 titik","Kanan atas, tanpa titik","Kiri bawah, tanpa titik","Tengah, 2 titik"],"correct_answer":"Kiri tengah, 1 titik"}'::jsonb, 3, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l5_q3', 'cyber_s1_u2_l5', 'input',
'Kotak: kiri-atas tanpa titik, kanan-atas 2 titik, kanan-tengah tanpa titik. Huruf apa? (3 kapital)',
'{"correct_answer":"AUD"}'::jsonb, 3, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l5_q4', 'cyber_s1_u2_l5', 'matching',
'Cocokkan kata dalam kotak dengan tulisannya!',
'{"pairs":[{"left":"S, A, Y, A","right":"SAYA"},{"left":"B, U, K, U","right":"BUKU"},{"left":"P, A, S, I, R","right":"PASIR"}]}'::jsonb, 4, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l5_q5', 'cyber_s1_u2_l5', 'sorting',
'Urutkan langkah membaca Sandi Kotak!',
'{"items":["Lihat gambar kotak","Tentukan baris (atas/tengah/bawah)","Tentukan kolom (kiri/tengah/kanan)","Hitung jumlah titik","Temukan huruf di tabel"],"correct_order":["Lihat gambar kotak","Tentukan baris (atas/tengah/bawah)","Tentukan kolom (kiri/tengah/kanan)","Hitung jumlah titik","Temukan huruf di tabel"]}'::jsonb, 4, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- LEVEL 6: Tulis kode sandi kotak (dari huruf ke kotak)
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l6_q1', 'cyber_s1_u2_l6', 'multiple_choice',
'Untuk menulis huruf "G" dalam Sandi Kotak 1, kamu menggambar...',
'{"options":["Kotak kanan tengah, tanpa titik","Kotak kiri tengah, 1 titik","Kotak kiri atas, 2 titik","Kotak tengah, tanpa titik"],"correct_answer":"Kotak kanan tengah, tanpa titik"}'::jsonb, 3, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l6_q2', 'cyber_s1_u2_l6', 'input',
'Untuk menulis "R", gambar kotak kanan bawah dengan... titik. (ketik angka)',
'{"correct_answer":"1"}'::jsonb, 2, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l6_q3', 'cyber_s1_u2_l6', 'multiple_choice',
'Kata "HOME" dalam Sandi Kotak 1: H=?, O=?, M=?, E=? Posisi huruf O adalah...',
'{"options":["Tengah bawah, 1 titik","Kanan tengah, 1 titik","Kiri bawah, 2 titik","Tengah, tanpa titik"],"correct_answer":"Tengah bawah, 1 titik"}'::jsonb, 3, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l6_q4', 'cyber_s1_u2_l6', 'matching',
'Cocokkan huruf dengan deskripsi kotak yang BENAR!',
'{"pairs":[{"left":"N","right":"Tengah tengah, 1 titik"},{"left":"T","right":"Kanan atas, 2 titik"},{"left":"Z","right":"Kanan bawah, 2 titik"}]}'::jsonb, 3, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l6_q5', 'cyber_s1_u2_l6', 'arrange_words',
'Susun huruf-huruf ini sesuai urutan baris dalam Sandi Kotak 1 (atas ke bawah)!',
'{"words":["A-B-C","D-E-F","G-H-I"],"correct_order":["A-B-C","D-E-F","G-H-I"]}'::jsonb, 3, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- LEVEL 7: Kata panjang & analisis
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l7_q1', 'cyber_s1_u2_l7', 'multiple_choice',
'Kata "PRAMUKA" dalam Sandi Kotak 1: P=?, R=?, A=?, M=?, U=?, K=?, A=?. Huruf M berada di...',
'{"options":["Tengah tengah, 1 titik","Kiri tengah, 1 titik","Kanan tengah, 1 titik","Tengah tengah, tanpa titik"],"correct_answer":"Tengah tengah, 1 titik"}'::jsonb, 3, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l7_q2', 'cyber_s1_u2_l7', 'input',
'Jika A=kotak kiri-atas tanpa titik dan Z=kotak kanan-bawah 2 titik, maka kata apa yang terbentuk dari: kiri-atas, kiri-atas? (2 huruf kapital)',
'{"correct_answer":"AA"}'::jsonb, 3, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l7_q3', 'cyber_s1_u2_l7', 'vuln_spotter',
'Temukan huruf yang SALAH ditempatkan dalam Sandi Kotak 1!',
'{"description":"Temukan huruf yang posisi kotaknya SALAH!","elements":[{"x":0.02,"y":0.02,"w":0.46,"h":0.18,"label":"A = kiri atas, tanpa titik","is_vuln":false,"vuln_type":""},{"x":0.52,"y":0.02,"w":0.46,"h":0.18,"label":"B = kanan atas, tanpa titik","is_vuln":true,"vuln_type":"B harusnya tengah atas"},{"x":0.02,"y":0.24,"w":0.46,"h":0.18,"label":"D = kiri tengah, tanpa titik","is_vuln":false,"vuln_type":""},{"x":0.52,"y":0.24,"w":0.46,"h":0.18,"label":"M = tengah tengah, 2 titik","is_vuln":true,"vuln_type":"M harusnya 1 titik"},{"x":0.02,"y":0.46,"w":0.46,"h":0.18,"label":"S = kiri atas, 2 titik","is_vuln":false,"vuln_type":""},{"x":0.52,"y":0.46,"w":0.46,"h":0.18,"label":"Z = kiri atas, tanpa titik","is_vuln":true,"vuln_type":"Z harusnya kanan bawah"},{"x":0.02,"y":0.68,"w":0.46,"h":0.18,"label":"P = kiri bawah, 1 titik","is_vuln":false,"vuln_type":""},{"x":0.52,"y":0.68,"w":0.46,"h":0.18,"label":"J = kiri tengah, 1 titik","is_vuln":false,"vuln_type":""}],"total_vulns":3}'::jsonb, 6, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l7_q4', 'cyber_s1_u2_l7', 'input',
'Kata "SIAGA" dalam Sandi Kotak 1 diawali dengan huruf S (kiri-atas, 2 titik). Huruf A kedua sama dengan huruf pertama. Ada berapa huruf A dalam SIAGA? (Ketik angka)',
'{"correct_answer":"3"}'::jsonb, 3, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l7_q5', 'cyber_s1_u2_l7', 'matching',
'Cocokkan kata dengan kode Sandi Kotak 1 yang benar!',
'{"pairs":[{"left":"B, U, D, I","right":"BUDI"},{"left":"A, D, I, K","right":"ADIK"},{"left":"K, A, K, A","right":"KAKA"}]}'::jsonb, 4, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- LEVEL 8: Kombinasi dan logika
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l8_q1', 'cyber_s1_u2_l8', 'network_cutter',
'Potong hubungan yang SALAH! Hanya sambungkan huruf dengan posisi yang benar!',
'{"nodes":[{"id":"a_huruf","x":0.15,"y":0.15,"type":"server","label":"Huruf A"},{"id":"posisi_a","x":0.85,"y":0.15,"type":"client","label":"Kiri-atas, 0 titik"},{"id":"huruf_p","x":0.15,"y":0.45,"type":"server","label":"Huruf P"},{"id":"posisi_p","x":0.85,"y":0.45,"type":"client","label":"Kiri-bawah, 1 titik"},{"id":"huruf_w","x":0.15,"y":0.75,"type":"client","label":"Huruf W"},{"id":"posisi_w","x":0.85,"y":0.75,"type":"db","label":"Tengah, 2 titik"}],"edges":[{"from":"a_huruf","to":"posisi_a","malicious":false},{"from":"huruf_p","to":"posisi_p","malicious":false},{"from":"huruf_p","to":"posisi_a","malicious":true},{"from":"huruf_w","to":"posisi_w","malicious":false},{"from":"a_huruf","to":"posisi_w","malicious":true}],"target_count":2}'::jsonb, 6, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l8_q2', 'cyber_s1_u2_l8', 'multiple_choice',
'Jika Sandi Kotak 1 hanya punya 9 kotak, bagaimana cara menulis 26 huruf?',
'{"options":["Pakai titik sebagai pembeda","Pakai warna berbeda","Geser kotaknya","Tambah garis miring"],"correct_answer":"Pakai titik sebagai pembeda"}'::jsonb, 3, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l8_q3', 'cyber_s1_u2_l8', 'sorting',
'Urutkan proses menulis kata "P3K" dalam Sandi Kotak 1!',
'{"items":["Cari huruf P (kiri-bawah, 1 titik)","Cari angka 3? Tunggu, Sandi Kotak hanya untuk huruf","Cari huruf K (kiri-tengah, 1 titik)","Simpulkan: P3K tidak bisa ditulis langsung"],"correct_order":["Cari huruf P (kiri-bawah, 1 titik)","Cari huruf K (kiri-tengah, 1 titik)","Cari angka 3? Tunggu, Sandi Kotak hanya untuk huruf","Simpulkan: P3K tidak bisa ditulis langsung"]}'::jsonb, 4, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l8_q4', 'cyber_s1_u2_l8', 'input',
'Berapa jumlah titik maksimal dalam satu kotak Sandi Kotak 1? (Ketik angka)',
'{"correct_answer":"2"}'::jsonb, 2, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l8_q5', 'cyber_s1_u2_l8', 'multiple_choice',
'Sandi Kotak 1 disebut "Kotak 1" karena...',
'{"options":["Ini yang pertama diajarkan","Hanya pakai 1 kotak","Ada 1 titik","Untuk 1 orang"],"correct_answer":"Ini yang pertama diajarkan"}'::jsonb, 2, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- LEVEL 9: Tantangan decode
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l9_q1', 'cyber_s1_u2_l9', 'multiple_choice',
'Kode kotak: (kiri-atas,1 titik) (tengah-atas,0 titik) (kanan-tengah,0 titik) = ?',
'{"options":["JBG","JCH","JAG","KBG"],"correct_answer":"JBG"}'::jsonb, 4, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l9_q2', 'cyber_s1_u2_l9', 'input',
'Decode: (kiri-atas) (kiri-tengah) (kiri-bawah) dengan 0 titik semua. Kata apa? (3 kapital)',
'{"correct_answer":"ADG"}'::jsonb, 3, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l9_q3', 'cyber_s1_u2_l9', 'packet_sweeper',
'Geser ke KANAN jika decode Sandi Kotak BENAR, ke KIRI jika SALAH!',
'{"packets":[{"protocol":"KOTAK1","source":"Decoder","dest":"Tebakan","method":"Decode","payload_preview":"A+B+C = ABC","is_malicious":false},{"protocol":"KOTAK1","source":"Decoder","dest":"Tebakan","method":"Decode","payload_preview":"J+K+L = ABC","is_malicious":true},{"protocol":"KOTAK1","source":"Decoder","dest":"Tebakan","method":"Decode","payload_preview":"S+T+U = STU","is_malicious":false},{"protocol":"KOTAK1","source":"Decoder","dest":"Tebakan","method":"Decode","payload_preview":"A+D+G = ADG","is_malicious":false}]}'::jsonb, 5, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l9_q4', 'cyber_s1_u2_l9', 'arrange_words',
'Susun decode yang benar untuk: (kiri-atas,0) (tengah-atas,0) (kanan-atas,0)',
'{"words":["A","B","C"],"correct_order":["A","B","C"]}'::jsonb, 3, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l9_q5', 'cyber_s1_u2_l9', 'input',
'Decode: (kanan-atas,0) (kiri-bawah,1) (kiri-atas,2) = 3 huruf kapital',
'{"correct_answer":"CPS"}'::jsonb, 3, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- LEVEL 10: Final Challenge Sandi Kotak
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l10_q1', 'cyber_s1_u2_l10', 'network_cutter',
'Potong hubungan yang SALAH! Sambungkan hanya huruf dengan posisi Sandi Kotak yang benar!',
'{"nodes":[{"id":"h_A","x":0.15,"y":0.1,"type":"server","label":"Huruf A"},{"id":"h_M","x":0.15,"y":0.3,"type":"server","label":"Huruf M"},{"id":"h_S","x":0.15,"y":0.5,"type":"server","label":"Huruf S"},{"id":"h_Z","x":0.15,"y":0.7,"type":"client","label":"Huruf Z"},{"id":"p_A","x":0.85,"y":0.1,"type":"client","label":"Kiri-atas, 0 titik"},{"id":"p_M","x":0.85,"y":0.3,"type":"client","label":"Tengah-tengah, 1 titik"},{"id":"p_S","x":0.85,"y":0.5,"type":"client","label":"Kiri-atas, 2 titik"},{"id":"p_Z","x":0.85,"y":0.7,"type":"db","label":"Kanan-bawah, 2 titik"}],"edges":[{"from":"h_A","to":"p_A","malicious":false},{"from":"h_M","to":"p_M","malicious":false},{"from":"h_S","to":"p_S","malicious":false},{"from":"h_Z","to":"p_Z","malicious":false},{"from":"h_A","to":"p_Z","malicious":true},{"from":"h_Z","to":"p_A","malicious":true}],"target_count":2}'::jsonb, 6, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l10_q2', 'cyber_s1_u2_l10', 'matching',
'Cocokkan huruf dengan jumlah titik yang benar dalam Sandi Kotak 1!',
'{"pairs":[{"left":"A, B, C, D, E, F, G, H, I","right":"0 titik"},{"left":"J, K, L, M, N, O, P, Q, R","right":"1 titik"},{"left":"S, T, U, V, W, X, Y, Z","right":"2 titik"}]}'::jsonb, 5, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l10_q3', 'cyber_s1_u2_l10', 'multiple_choice',
'Kata apa yang dihasilkan dari: (kiri-atas,2) (tengah-atas,1) (kiri-bawah,0) (kanan-tengah,1)?',
'{"options":["SGPQ","SKPQ","SJPG","SKPG"],"correct_answer":"SKPG"}'::jsonb, 5, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l10_q4', 'cyber_s1_u2_l10', 'input',
'Final decode: (kanan-atas,0) (kiri-tengah,1) (tengah-atas,0) (kanan-bawah,2) = 4 huruf kapital',
'{"correct_answer":"CJAZ"}'::jsonb, 4, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u2_l10_q5', 'cyber_s1_u2_l10', 'multiple_choice',
'Setelah belajar Sandi Kotak 1, mana yang PALING BENAR?',
'{"options":["Sandi Kotak menggunakan 9 kotak + titik untuk 26 huruf","Sandi Kotak hanya untuk 9 huruf","Sandi Kotak pakai 26 kotak","Sandi Kotak tidak pakai titik"],"correct_answer":"Sandi Kotak menggunakan 9 kotak + titik untuk 26 huruf"}'::jsonb, 3, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;
