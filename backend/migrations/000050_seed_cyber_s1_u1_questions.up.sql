-- Seed 50 Soal untuk Cyber Scout Bagian 1 Unit 1: "Apa Itu Sandi?"
-- 10 level x 5 soal = 50 soal dengan tipe beragam & interaktif
-- Progresi: dari pengertian dasar → sejarah → jenis → fungsi → aplikasi → enkripsi → analisis → challenge

-- ============================================================
-- UPDATE LEVELS: set total_questions & min_correct
-- ============================================================
UPDATE training_levels SET total_questions = 5, min_correct = 3
WHERE id IN (
    'cyber_s1_u1_l1','cyber_s1_u1_l2','cyber_s1_u1_l3','cyber_s1_u1_l4','cyber_s1_u1_l5',
    'cyber_s1_u1_l6','cyber_s1_u1_l7','cyber_s1_u1_l8','cyber_s1_u1_l9','cyber_s1_u1_l10'
);

-- ============================================================
-- LEVEL 1: Pengertian dasar sandi (termudah)
-- ============================================================
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l1_q1', 'cyber_s1_u1_l1', 'multiple_choice',
'Dalam Pramuka, apa yang dimaksud dengan sandi?',
'{"options":["Tulisan rahasia","Tali temali","Mendaki gunung","Memasak"],"correct_answer":"Tulisan rahasia"}'::jsonb, 2, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l1_q2', 'cyber_s1_u1_l1', 'multiple_choice',
'Sandi sudah digunakan manusia sejak...',
'{"options":["Zaman kuno","Tahun 2000","Tahun 1900","Tahun 2010"],"correct_answer":"Zaman kuno"}'::jsonb, 2, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l1_q3', 'cyber_s1_u1_l1', 'matching',
'Cocokkan istilah sandi dengan artinya!',
'{"pairs":[{"left":"Sandi","right":"Pesan rahasia"},{"left":"Enkripsi","right":"Mengubah jadi sandi"},{"left":"Dekripsi","right":"Membaca sandi"},{"left":"Kunci","right":"Cara membuka sandi"}]}'::jsonb, 3, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l1_q4', 'cyber_s1_u1_l1', 'multiple_choice',
'Sandi hanya digunakan oleh militer dan mata-mata. Benar atau salah?',
'{"options":["Salah","Benar"],"correct_answer":"Salah"}'::jsonb, 2, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l1_q5', 'cyber_s1_u1_l1', 'input',
'Sandi adalah cara menulis pesan secara...',
'{"correct_answer":"rahasia"}'::jsonb, 2, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- ============================================================
-- LEVEL 2: Sejarah sandi
-- ============================================================
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l2_q1', 'cyber_s1_u1_l2', 'multiple_choice',
'Julius Caesar menggunakan sandi dengan cara...',
'{"options":["Menggeser huruf","Menukar huruf","Menghapus huruf","Menambahkan huruf"],"correct_answer":"Menggeser huruf"}'::jsonb, 2, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l2_q2', 'cyber_s1_u1_l2', 'multiple_choice',
'Di Pramuka Indonesia, sandi pertama yang diajarkan biasanya...',
'{"options":["Sandi Kotak","Sandi Morse","Sandi Angka","Sandi Rumput"],"correct_answer":"Sandi Kotak"}'::jsonb, 2, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l2_q3', 'cyber_s1_u1_l2', 'sorting',
'Urutkan sejarah sandi dari yang paling TUA!',
'{"items":["Sandi Caesar (Romawi Kuno)","Sandi Morse (1836)","Enigma (Perang Dunia II)","Sandi Kotak Pramuka"],"correct_order":["Sandi Caesar (Romawi Kuno)","Sandi Morse (1836)","Enigma (Perang Dunia II)","Sandi Kotak Pramuka"]}'::jsonb, 3, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l2_q4', 'cyber_s1_u1_l2', 'arrange_words',
'Susun kata-kata ini menjadi kalimat yang benar!',
'{"words":["Sandi","digunakan","sejak","zaman","kuno"],"correct_order":["Sandi","digunakan","sejak","zaman","kuno"]}'::jsonb, 3, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l2_q5', 'cyber_s1_u1_l2', 'matching',
'Cocokkan tokoh dengan penemuannya!',
'{"pairs":[{"left":"Julius Caesar","right":"Sandi geser huruf"},{"left":"Samuel Morse","right":"Sandi titik dan garis"},{"left":"Pramuka","right":"Sandi Kotak"},{"left":"Alan Turing","right":"Pemecah sandi Enigma"}]}'::jsonb, 3, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- ============================================================
-- LEVEL 3: Jenis sandi dasar (mulai interaktif: cipher_rotor)
-- ============================================================
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l3_q1', 'cyber_s1_u1_l3', 'matching',
'Cocokkan jenis sandi dengan ciri khasnya!',
'{"pairs":[{"left":"Sandi Kotak","right":"Huruf dalam kotak-kotak"},{"left":"Sandi Morse","right":"Titik dan garis"},{"left":"Sandi Angka","right":"A=1, B=2, C=3"},{"left":"Sandi Caesar","right":"Menggeser abjad"}]}'::jsonb, 3, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l3_q2', 'cyber_s1_u1_l3', 'multiple_choice',
'Sandi yang menggunakan titik (.) dan garis (-) disebut...',
'{"options":["Sandi Morse","Sandi Kotak","Sandi Angka","Sandi Rumput"],"correct_answer":"Sandi Morse"}'::jsonb, 2, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l3_q3', 'cyber_s1_u1_l3', 'cipher_rotor',
'Pesan rahasia "BCD" adalah hasil enkripsi. Putar roda untuk menemukan pesan aslinya! (Petunjuk: digeser 1 langkah)',
'{"encrypted_text":"BCD","correct_shift":1,"hint":"Coba geser roda ke angka 1"}'::jsonb, 4, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l3_q4', 'cyber_s1_u1_l3', 'input',
'Kebalikan dari enkripsi (mengubah jadi sandi) adalah...',
'{"correct_answer":"dekripsi"}'::jsonb, 2, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l3_q5', 'cyber_s1_u1_l3', 'multiple_choice',
'Sandi A=1, B=2, C=3 dan seterusnya disebut sandi...',
'{"options":["Sandi Angka","Sandi Kotak","Sandi Morse","Sandi Caesar"],"correct_answer":"Sandi Angka"}'::jsonb, 2, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- ============================================================
-- LEVEL 4: Fungsi sandi (interaktif: packet_sweeper)
-- ============================================================
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l4_q1', 'cyber_s1_u1_l4', 'packet_sweeper',
'Geser ke KANAN jika ini CONTOH sandi, ke KIRI jika BUKAN!',
'{"packets":[{"protocol":"SANDI","source":"Pramuka","dest":"Anggota","method":"Sandi Kotak","payload_preview":"Pesan dalam kotak-kotak","is_malicious":false},{"protocol":"BIASA","source":"Sekolah","dest":"Siswa","method":"Catatan","payload_preview":"Rumus matematika","is_malicious":true},{"protocol":"SANDI","source":"Tentara","dest":"Pasukan","method":"Caesar","payload_preview":"Menggeser huruf","is_malicious":false},{"protocol":"BIASA","source":"Teman","dest":"Teman","method":"Ngobrol","payload_preview":"Pesan biasa","is_malicious":true}]}'::jsonb, 5, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l4_q2', 'cyber_s1_u1_l4', 'multiple_choice',
'Mengapa Pramuka perlu belajar sandi?',
'{"options":["Untuk komunikasi rahasia","Untuk bermain-main","Untuk nilai sekolah","Untuk lomba lari"],"correct_answer":"Untuk komunikasi rahasia"}'::jsonb, 2, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l4_q3', 'cyber_s1_u1_l4', 'arrange_words',
'Susun kata-kata ini menjadi kalimat yang benar!',
'{"words":["Sandi","membantu","komunikasi","rahasia","Pramuka"],"correct_order":["Sandi","membantu","komunikasi","rahasia","Pramuka"]}'::jsonb, 3, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l4_q4', 'cyber_s1_u1_l4', 'matching',
'Cocokkan fungsi sandi dalam kehidupan!',
'{"pairs":[{"left":"Sandi Kotak","right":"Komunikasi rahasia regu"},{"left":"Sandi Morse","right":"Komunikasi jarak jauh"},{"left":"Enkripsi","right":"Melindungi data digital"},{"left":"Password","right":"Menjaga akun pribadi"}]}'::jsonb, 3, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l4_q5', 'cyber_s1_u1_l4', 'input',
'Sandi berfungsi untuk... informasi agar tidak diketahui orang lain.',
'{"correct_answer":"menyembunyikan"}'::jsonb, 2, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- ============================================================
-- LEVEL 5: Sandi dalam kehidupan sehari-hari
-- ============================================================
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l5_q1', 'cyber_s1_u1_l5', 'multiple_choice',
'Contoh sandi dalam kehidupan sehari-hari adalah...',
'{"options":["Password WiFi","Nomor telepon","Alamat rumah","Nama lengkap"],"correct_answer":"Password WiFi"}'::jsonb, 2, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l5_q2', 'cyber_s1_u1_l5', 'packet_sweeper',
'Geser ke KANAN jika ini CONTOH sandi, ke KIRI jika BUKAN!',
'{"packets":[{"protocol":"SANDI","source":"Digital","dest":"Akun","method":"Password","payload_preview":"Password email: ********","is_malicious":false},{"protocol":"SANDI","source":"Pramuka","dest":"Anggota","method":"Kotak","payload_preview":"Buku sandi regu","is_malicious":false},{"protocol":"BUKAN","source":"Dapur","dest":"Meja","method":"Resep","payload_preview":"Resep masakan ibu","is_malicious":true},{"protocol":"SANDI","source":"HP","dest":"Laptop","method":"Enkripsi","payload_preview":"Chat WA terenkripsi","is_malicious":false}]}'::jsonb, 5, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l5_q3', 'cyber_s1_u1_l5', 'matching',
'Cocokkan situasi dengan jenis perlindungannya!',
'{"pairs":[{"left":"Buka HP","right":"PIN/Sandi angka"},{"left":"Login Instagram","right":"Password"},{"left":"Kirim chat rahasia","right":"Enkripsi"},{"left":"Sandi Pramuka","right":"Sandi Kotak"}]}'::jsonb, 3, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l5_q4', 'cyber_s1_u1_l5', 'multiple_choice',
'Password komputer termasuk sandi karena berupa...',
'{"options":["Kode rahasia","Tampilan biasa","Barang fisik","Makanan"],"correct_answer":"Kode rahasia"}'::jsonb, 2, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l5_q5', 'cyber_s1_u1_l5', 'input',
'PIN ATM adalah bentuk sandi... yang kita pakai sehari-hari.',
'{"correct_answer":"angka"}'::jsonb, 2, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- ============================================================
-- LEVEL 6: Konsep enkripsi (cipher_rotor dengan shift 3)
-- ============================================================
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l6_q1', 'cyber_s1_u1_l6', 'cipher_rotor',
'Pesan "KHOOR" adalah hasil enkripsi dari kata "HELLO". Cari shift yang tepat!',
'{"encrypted_text":"KHOOR","correct_shift":3,"hint":"Coba geser roda ke angka 3"}'::jsonb, 4, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l6_q2', 'cyber_s1_u1_l6', 'multiple_choice',
'Proses mengubah pesan asli menjadi pesan sandi disebut...',
'{"options":["Enkripsi","Dekripsi","Revisi","Komposisi"],"correct_answer":"Enkripsi"}'::jsonb, 2, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l6_q3', 'cyber_s1_u1_l6', 'sorting',
'Urutkan proses komunikasi rahasia dari awal hingga selesai!',
'{"items":["Tulis pesan asli","Enkripsi jadi sandi","Kirim pesan","Terima pesan","Dekripsi pesan"],"correct_order":["Tulis pesan asli","Enkripsi jadi sandi","Kirim pesan","Terima pesan","Dekripsi pesan"]}'::jsonb, 3, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l6_q4', 'cyber_s1_u1_l6', 'matching',
'Cocokkan istilah dengan artinya!',
'{"pairs":[{"left":"Enkripsi","right":"Mengubah jadi sandi"},{"left":"Dekripsi","right":"Membuka sandi"},{"left":"Kunci","right":"Cara membuka sandi"},{"left":"Plaintext","right":"Pesan asli"}]}'::jsonb, 3, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l6_q5', 'cyber_s1_u1_l6', 'multiple_choice',
'Enkripsi hanya bisa digunakan di komputer. Benar atau salah?',
'{"options":["Salah","Benar"],"correct_answer":"Salah"}'::jsonb, 2, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- ============================================================
-- LEVEL 7: Penerapan sandi (cipher_rotor shift 5 + vuln_spotter)
-- ============================================================
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l7_q1', 'cyber_s1_u1_l7', 'multiple_choice',
'Dalam dunia digital, proses mengubah data jadi kode rahasia disebut...',
'{"options":["Enkripsi digital","Sandi Kotak","Sandi Morse","Bendera semapur"],"correct_answer":"Enkripsi digital"}'::jsonb, 2, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l7_q2', 'cyber_s1_u1_l7', 'cipher_rotor',
'Pesan "XHTZY" adalah kode untuk "SCOUT". Geser roda ke shift yang tepat!',
'{"encrypted_text":"XHTZY","correct_shift":5,"hint":"Coba geser ke angka 5 — SCOUT adalah istilah kepramukaan dunia!"}'::jsonb, 4, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l7_q3', 'cyber_s1_u1_l7', 'vuln_spotter',
'Temukan praktik penggunaan sandi yang RENTAN dan berbahaya!',
'{"description":"Temukan praktik keamanan sandi yang buruk!","elements":[{"x":0.02,"y":0.02,"w":0.46,"h":0.18,"label":"Password: bismillah123","is_vuln":true,"vuln_type":"Password lemah"},{"x":0.52,"y":0.02,"w":0.46,"h":0.18,"label":"Password beda tiap akun","is_vuln":false,"vuln_type":""},{"x":0.02,"y":0.24,"w":0.46,"h":0.18,"label":"Tulis sandi di sticky note","is_vuln":true,"vuln_type":"Kunci terekspos"},{"x":0.52,"y":0.24,"w":0.46,"h":0.18,"label":"Ganti password rutin","is_vuln":false,"vuln_type":""},{"x":0.02,"y":0.46,"w":0.46,"h":0.18,"label":"Password: Te5@r!23","is_vuln":false,"vuln_type":""},{"x":0.52,"y":0.46,"w":0.46,"h":0.18,"label":"Password sama semua akun","is_vuln":true,"vuln_type":"Kunci seragam"},{"x":0.02,"y":0.68,"w":0.46,"h":0.18,"label":"Aktifkan 2FA","is_vuln":false,"vuln_type":""},{"x":0.52,"y":0.68,"w":0.46,"h":0.18,"label":"PIN pakai tanggal lahir","is_vuln":true,"vuln_type":"Mudah ditebak"}],"total_vulns":4}'::jsonb, 6, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l7_q4', 'cyber_s1_u1_l7', 'arrange_words',
'Susun menjadi kalimat yang benar!',
'{"words":["Sandi","melindungi","data","kita","setiap","hari"],"correct_order":["Sandi","melindungi","data","kita","setiap","hari"]}'::jsonb, 3, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l7_q5', 'cyber_s1_u1_l7', 'matching',
'Cocokkan alat pelindung dengan fungsinya!',
'{"pairs":[{"left":"Password","right":"Melindungi akun"},{"left":"Enkripsi","right":"Mengamankan data"},{"left":"Sandi Kotak","right":"Komunikasi regu"},{"left":"PIN","right":"Kode pribadi"}]}'::jsonb, 3, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- ============================================================
-- LEVEL 8: Analisis sandi (cipher_rotor shift 2)
-- ============================================================
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l8_q1', 'cyber_s1_u1_l8', 'cipher_rotor',
'Pesan "RTCQW" adalah "PRAMU" yang dienkripsi. Temukan shift yang tepat!',
'{"encrypted_text":"RTCQW","correct_shift":2,"hint":"Coba geser ke angka 2 — PRAMU adalah singkatan Pramuka"}'::jsonb, 4, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l8_q2', 'cyber_s1_u1_l8', 'multiple_choice',
'Jika A=1, B=2, C=3 maka kata "SANDI" dalam sandi angka adalah...',
'{"options":["19,1,14,4,9","18,2,13,3,8","20,3,15,5,10","17,4,12,6,11"],"correct_answer":"19,1,14,4,9"}'::jsonb, 3, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l8_q3', 'cyber_s1_u1_l8', 'input',
'Proses mengembalikan pesan sandi ke pesan asli disebut...',
'{"correct_answer":"dekripsi"}'::jsonb, 2, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l8_q4', 'cyber_s1_u1_l8', 'sorting',
'Urutkan langkah memecahkan sandi Caesar!',
'{"items":["Lihat teks sandi","Coba geser huruf","Temukan kata yang masuk akal","Catat kunci yang ditemukan"],"correct_order":["Lihat teks sandi","Coba geser huruf","Temukan kata yang masuk akal","Catat kunci yang ditemukan"]}'::jsonb, 3, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l8_q5', 'cyber_s1_u1_l8', 'matching',
'Cocokkan istilah dengan lawan katanya!',
'{"pairs":[{"left":"Enkripsi","right":"Dekripsi"},{"left":"Ciphertext","right":"Plaintext"},{"left":"Pesan sandi","right":"Pesan asli"},{"left":"Kunci enkripsi","right":"Kunci dekripsi"}]}'::jsonb, 3, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- ============================================================
-- LEVEL 9: Kombinasi & kriptanalisis (cipher_rotor shift 7 + vuln_spotter)
-- ============================================================
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l9_q1', 'cyber_s1_u1_l9', 'cipher_rotor',
'Pesan "OLSSV" adalah kode. Geser roda sampai menemukan kata "HELLO"! (petunjuk: geser 7)',
'{"encrypted_text":"OLSSV","correct_shift":7,"hint":"Geser roda sampai teks menjadi HELLO"}'::jsonb, 5, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l9_q2', 'cyber_s1_u1_l9', 'multiple_choice',
'Teknik memecahkan sandi dengan mencoba semua kemungkinan kunci disebut...',
'{"options":["Brute Force","Mantra","Ramalan","Tebakan"],"correct_answer":"Brute Force"}'::jsonb, 2, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l9_q3', 'cyber_s1_u1_l9', 'vuln_spotter',
'Temukan praktik KEAMANAN SANDI yang BURUK!',
'{"description":"Temukan praktik keamanan sandi yang buruk!","elements":[{"x":0.02,"y":0.02,"w":0.46,"h":0.18,"label":"Kirim password via chat","is_vuln":true,"vuln_type":"Data bocor"},{"x":0.52,"y":0.02,"w":0.46,"h":0.18,"label":"Gunakan password manager","is_vuln":false,"vuln_type":""},{"x":0.02,"y":0.24,"w":0.46,"h":0.18,"label":"Password: admin123","is_vuln":true,"vuln_type":"Mudah ditebak"},{"x":0.52,"y":0.24,"w":0.46,"h":0.18,"label":"Password: G0lf@ng!23","is_vuln":false,"vuln_type":""},{"x":0.02,"y":0.46,"w":0.46,"h":0.18,"label":"Gunakan sandi kotak","is_vuln":false,"vuln_type":""},{"x":0.52,"y":0.46,"w":0.46,"h":0.18,"label":"Bagikan kunci ke semua orang","is_vuln":true,"vuln_type":"Kunci bocor"},{"x":0.02,"y":0.68,"w":0.46,"h":0.18,"label":"Ganti PIN berkala","is_vuln":false,"vuln_type":""},{"x":0.52,"y":0.68,"w":0.46,"h":0.18,"label":"PIN pakai tanggal lahir","is_vuln":true,"vuln_type":"Mudah ditebak"}],"total_vulns":4}'::jsonb, 6, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l9_q4', 'cyber_s1_u1_l9', 'multiple_choice',
'Sandi yang baik sebaiknya...',
'{"options":["Sulit ditebak orang lain","Mudah ditebak","Sama dengan username","Pakai tanggal lahir"],"correct_answer":"Sulit ditebak orang lain"}'::jsonb, 2, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l9_q5', 'cyber_s1_u1_l9', 'input',
'Nama lain untuk pemecah sandi adalah...',
'{"correct_answer":"kriptanalis"}'::jsonb, 3, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

-- ============================================================
-- LEVEL 10: Final Challenge (semua tipe, review total)
-- ============================================================
INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l10_q1', 'cyber_s1_u1_l10', 'cipher_rotor',
'Pesan "JFILY" adalah "CYBER" yang dienkripsi. Temukan shift-nya untuk lulus!',
'{"encrypted_text":"JFILY","correct_shift":7,"hint":"Ini adalah nama kursus yang sedang kamu pelajari — CYBER!"}'::jsonb, 5, 1)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l10_q2', 'cyber_s1_u1_l10', 'multiple_choice',
'Semua ilmu tentang sandi dan kode rahasia disebut...',
'{"options":["Kriptografi","Matematika","Fisika","Biologi"],"correct_answer":"Kriptografi"}'::jsonb, 3, 2)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l10_q3', 'cyber_s1_u1_l10', 'network_cutter',
'Potong hubungan yang SALAH! Hanya sambungkan konsep yang benar-benar berhubungan!',
'{"nodes":[{"id":"caesar","x":0.2,"y":0.15,"type":"server","label":"Sandi Caesar"},{"id":"geser","x":0.8,"y":0.15,"type":"client","label":"Geser Huruf"},{"id":"julius","x":0.2,"y":0.75,"type":"client","label":"Julius Caesar"},{"id":"kotak","x":0.8,"y":0.75,"type":"server","label":"Sandi Kotak"},{"id":"pramuka","x":0.5,"y":0.45,"type":"db","label":"Pramuka"}],"edges":[{"from":"caesar","to":"geser","malicious":false},{"from":"caesar","to":"julius","malicious":false},{"from":"caesar","to":"pramuka","malicious":true},{"from":"kotak","to":"pramuka","malicious":false},{"from":"kotak","to":"julius","malicious":true}],"target_count":2}'::jsonb, 6, 3)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l10_q4', 'cyber_s1_u1_l10', 'sorting',
'Urutkan tingkat kekuatan sandi dari yang TERLEMAH ke TERKUAT!',
'{"items":["123456","bismillah123","Pramuka2024!","G0lf@ng#S4nd1"],"correct_order":["123456","bismillah123","Pramuka2024!","G0lf@ng#S4nd1"]}'::jsonb, 4, 4)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;

INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES
('cyber_s1_u1_l10_q5', 'cyber_s1_u1_l10', 'matching',
'Cocokkan konsep dengan contoh nyatanya!',
'{"pairs":[{"left":"Sandi Caesar","right":"Geser abjad 3 huruf"},{"left":"Sandi Morse","right":"Titik dan garis"},{"left":"Sandi Kotak","right":"Kotak-kotak Pramuka"},{"left":"Enkripsi modern","right":"AES, RSA, HTTPS"}]}'::jsonb, 4, 5)
ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;
