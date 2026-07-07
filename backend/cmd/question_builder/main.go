package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"
)

type Question struct {
	ID       string      `json:"id"`
	LevelID  string      `json:"level_id"`
	Type     string      `json:"type"`
	Question string      `json:"question"`
	Payload  interface{} `json:"payload"`
	XP       int         `json:"xp"`
	Order    int         `json:"order"`
}

func main() {
	var questions []Question

	sections := []string{"puk", "ppgd", "nav", "tali", "sandi"}

	for _, sec := range sections {
		for lvl := 1; lvl <= 5; lvl++ {
			levelID := fmt.Sprintf("%s_u1_l%d", sec, lvl)
			qs := generateQuestionsForSection(sec, levelID, lvl)
			questions = append(questions, qs...)
		}
	}

	writeSQLFiles(questions)
}

func generateQuestionsForSection(sec, levelID string, lvl int) []Question {
	var qs []Question

	// Base XP increases with level
	baseXP := 2 + (lvl - 1)

	switch sec {
	case "puk":
		qs = []Question{
			{ID: levelID + "_q1", LevelID: levelID, Type: "multiple_choice", Question: fmt.Sprintf("Kamu sedang dalam ujian SKU Tingkat %d. Simbol apa yang menjadi lambang Gerakan Pramuka?", lvl), Payload: map[string]interface{}{"options": []string{"Tunas Kelapa", "Bintang", "Padi dan Kapas", "Burung Garuda"}, "correct_answer": "Tunas Kelapa"}, XP: baseXP, Order: 1},
			{ID: levelID + "_q2", LevelID: levelID, Type: "sorting", Question: "Susunlah urutan tingkatan dalam Pramuka berdasarkan usia dari yang termuda!", Payload: map[string]interface{}{"items": []string{"Siaga", "Penggalang", "Penegak", "Pandega"}, "correct_order": []string{"Siaga", "Penggalang", "Penegak", "Pandega"}}, XP: baseXP + 1, Order: 2},
			{ID: levelID + "_q3", LevelID: levelID, Type: "matching", Question: "Cocokkan warna dasar badge dengan tingkatan Pramuka yang tepat!", Payload: map[string]interface{}{"pairs": []map[string]string{{"left": "Hijau", "right": "Siaga"}, {"left": "Merah", "right": "Penggalang"}, {"left": "Kuning", "right": "Penegak"}}}, XP: baseXP + 2, Order: 3},
			{ID: levelID + "_q4", LevelID: levelID, Type: "arrange_words", Question: fmt.Sprintf("Seseorang merobek buku saku-mu! Susun kata-kata ini untuk membentuk Dasa Darma ke-%d", lvl), Payload: map[string]interface{}{"words": []string{"Patuh", "dan", "suka", "bermusyawarah", "Pramuka", "itu"}, "correct_order": []string{"Pramuka", "itu", "Patuh", "dan", "suka", "bermusyawarah"}}, XP: baseXP + 1, Order: 4},
			{ID: levelID + "_q5", LevelID: levelID, Type: "input", Question: "Bapak Pandu Dunia adalah Lord Baden... (Ketik nama belakangnya)", Payload: map[string]interface{}{"correct_answer": "Powell"}, XP: baseXP + 1, Order: 5},
		}
	case "ppgd":
		qs = []Question{
			{ID: levelID + "_q1", LevelID: levelID, Type: "multiple_choice", Question: "Teman regumu tiba-tiba mimisan saat kemah. Apa tindakan pertama yang paling tepat?", Payload: map[string]interface{}{"options": []string{"Mendongakkan kepala ke atas", "Menundukkan kepala dan memencet hidung", "Menyuruhnya berbaring rata", "Mengompres leher dengan air hangat"}, "correct_answer": "Menundukkan kepala dan memencet hidung"}, XP: baseXP, Order: 1},
			{ID: levelID + "_q2", LevelID: levelID, Type: "sorting", Question: "Kecelakaan terjadi! Susun langkah-langkah pertolongan pertama (DRCAB) yang benar!", Payload: map[string]interface{}{"items": []string{"Danger (Aman diri & lingkungan)", "Response (Cek kesadaran)", "Call for help (Minta bantuan)", "Airway (Cek jalan napas)"}, "correct_order": []string{"Danger (Aman diri & lingkungan)", "Response (Cek kesadaran)", "Call for help (Minta bantuan)", "Airway (Cek jalan napas)"}}, XP: baseXP + 2, Order: 2},
			{ID: levelID + "_q3", LevelID: levelID, Type: "matching", Question: "Cocokkan jenis luka dengan alat pertolongan yang tepat!", Payload: map[string]interface{}{"pairs": []map[string]string{{"left": "Luka Sayat", "right": "Plester & Betadine"}, {"left": "Patah Tulang", "right": "Bidai & Mitela"}, {"left": "Luka Bakar", "right": "Air mengalir"}}}, XP: baseXP + 1, Order: 3},
			{ID: levelID + "_q4", LevelID: levelID, Type: "arrange_words", Question: "Susun langkah membalut luka dengan mitela agar tidak mudah lepas!", Payload: map[string]interface{}{"words": []string{"Lipat", "mitela", "menjadi", "pita", "panjang", "lalu", "ikat", "menyilang"}, "correct_order": []string{"Lipat", "mitela", "menjadi", "pita", "panjang", "lalu", "ikat", "menyilang"}}, XP: baseXP, Order: 4},
			{ID: levelID + "_q5", LevelID: levelID, Type: "input", Question: "Tandu darurat biasanya dibuat dari tongkat pramuka dan tali temali. Apa nama kain segitiga yang sering digunakan dalam PPGD?", Payload: map[string]interface{}{"correct_answer": "Mitela"}, XP: baseXP + 1, Order: 5},
		}
	case "nav":
		qs = []Question{
			{ID: levelID + "_q1", LevelID: levelID, Type: "multiple_choice", Question: "Kamu tersesat di hutan dan tidak membawa kompas. Tanda alam apa yang paling akurat menunjukkan arah Matahari terbit?", Payload: map[string]interface{}{"options": []string{"Lumut di pohon", "Arah aliran sungai", "Posisi matahari pagi", "Arah angin"}, "correct_answer": "Posisi matahari pagi"}, XP: baseXP, Order: 1},
			{ID: levelID + "_q2", LevelID: levelID, Type: "sorting", Question: "Susun urutan bertahan hidup (STOP) jika kamu tersesat!", Payload: map[string]interface{}{"items": []string{"Sit (Duduk dan tenang)", "Think (Pikirkan situasi)", "Observe (Amati lingkungan)", "Plan (Buat rencana)"}, "correct_order": []string{"Sit (Duduk dan tenang)", "Think (Pikirkan situasi)", "Observe (Amati lingkungan)", "Plan (Buat rencana)"}}, XP: baseXP + 1, Order: 2},
			{ID: levelID + "_q3", LevelID: levelID, Type: "matching", Question: "Cocokkan metode mencari arah dengan media yang digunakan!", Payload: map[string]interface{}{"pairs": []map[string]string{{"left": "Kompas", "right": "Jarum magnetik"}, {"left": "Rasi Bintang Pari", "right": "Menunjuk arah Selatan"}, {"left": "Bayangan tongkat", "right": "Pergerakan matahari"}}}, XP: baseXP + 2, Order: 3},
			{ID: levelID + "_q4", LevelID: levelID, Type: "arrange_words", Question: "Buku panduan navigasimu basah! Susun kalimat ini untuk membaca peta dengan benar.", Payload: map[string]interface{}{"words": []string{"Samakan", "arah", "Utara", "peta", "dengan", "Utara", "kompas"}, "correct_order": []string{"Samakan", "arah", "Utara", "peta", "dengan", "Utara", "kompas"}}, XP: baseXP + 1, Order: 4},
			{ID: levelID + "_q5", LevelID: levelID, Type: "input", Question: "Teka-teki: Walau malam gelap gulita, aku selalu setia menunjuk arah Utara. Rasi bintang apakah aku? (Ketik satu kata saja)", Payload: map[string]interface{}{"correct_answer": "Biduk"}, XP: baseXP + 2, Order: 5},
		}
	case "tali":
		qs = []Question{
			{ID: levelID + "_q1", LevelID: levelID, Type: "multiple_choice", Question: "Tendamu hampir roboh ditiup angin kencang! Kamu harus segera mengikatkan tali tenda ke tiang pasak dengan ikatan yang kuat menjerat. Simpul apa yang akan menyelamatkanmu?", Payload: map[string]interface{}{"options": []string{"Simpul Pangkal", "Simpul Mati", "Simpul Anyam", "Simpul Jangkar"}, "correct_answer": "Simpul Pangkal"}, XP: baseXP, Order: 1},
			{ID: levelID + "_q2", LevelID: levelID, Type: "sorting", Question: "Susun urutan membuat 'Simpul Mati' agar dua tali pendek bisa disambung dengan kuat!", Payload: map[string]interface{}{"items": []string{"Siapkan ujung kedua tali", "Silangkan ujung kiri di atas kanan", "Silangkan ujung kanan di atas kiri", "Tarik kedua ujung hingga erat"}, "correct_order": []string{"Siapkan ujung kedua tali", "Silangkan ujung kiri di atas kanan", "Silangkan ujung kanan di atas kiri", "Tarik kedua ujung hingga erat"}}, XP: baseXP + 1, Order: 2},
			{ID: levelID + "_q3", LevelID: levelID, Type: "matching", Question: "Berpikir cepat! Cocokkan nama simpul di sebelah kiri dengan fungsi darurat yang tepat!", Payload: map[string]interface{}{"pairs": []map[string]string{{"left": "Simpul Mati", "right": "Menyambung 2 tali sama besar"}, {"left": "Simpul Pangkal", "right": "Mengikat erat tiang/kayu"}, {"left": "Simpul Anyam", "right": "Menyambung 2 tali beda ukuran"}}}, XP: baseXP + 2, Order: 3},
			{ID: levelID + "_q4", LevelID: levelID, Type: "arrange_words", Question: "Susun kembali potongan kertas ini untuk mengetahui fungsi dari Simpul Anyam Berganda.", Payload: map[string]interface{}{"words": []string{"untuk", "menyambung", "dua", "tali", "yang", "ukurannya", "sangat", "berbeda"}, "correct_order": []string{"untuk", "menyambung", "dua", "tali", "yang", "ukurannya", "sangat", "berbeda"}}, XP: baseXP + 1, Order: 4},
			{ID: levelID + "_q5", LevelID: levelID, Type: "input", Question: "Pecahkan teka-teki ini: Aku sangat berguna untuk mengawali dan mengakhiri sebuah ikatan pada tongkat pionering. Siapakah aku? (Ketik satu kata saja)", Payload: map[string]interface{}{"correct_answer": "Pangkal"}, XP: baseXP + 1, Order: 5},
		}
	case "sandi":
		qs = []Question{
			{ID: levelID + "_q1", LevelID: levelID, Type: "multiple_choice", Question: "Sebuah pesan rahasia mencegat regumu: '--/---/.-./.../.' Tahukah kamu apa artinya?", Payload: map[string]interface{}{"options": []string{"MORSE", "SANDI", "PRAMUKA", "SIAGA"}, "correct_answer": "MORSE"}, XP: baseXP, Order: 1},
			{ID: levelID + "_q2", LevelID: levelID, Type: "sorting", Question: "Pesan semaphore akan segera dikirim. Susun langkah persiapan yang tepat!", Payload: map[string]interface{}{"items": []string{"Berdiri tegak", "Pegang kedua bendera menyilang di bawah", "Beri isyarat perhatian (UR)", "Tunggu balasan (K) lalu mulai kirim"}, "correct_order": []string{"Berdiri tegak", "Pegang kedua bendera menyilang di bawah", "Beri isyarat perhatian (UR)", "Tunggu balasan (K) lalu mulai kirim"}}, XP: baseXP + 1, Order: 2},
			{ID: levelID + "_q3", LevelID: levelID, Type: "matching", Question: "Cocokkan huruf dengan kode morse-nya yang tepat agar sandi bisa terpecahkan!", Payload: map[string]interface{}{"pairs": []map[string]string{{"left": "A", "right": ".-"}, {"left": "B", "right": "-..."}, {"left": "C", "right": "-.-."}, {"left": "S", "right": "..."}}}, XP: baseXP + 2, Order: 3},
			{ID: levelID + "_q4", LevelID: levelID, Type: "arrange_words", Question: "Ada kode Sandi AN berbunyi: 'CENZHXN'. Susun huruf aslinya menjadi kata yang benar!", Payload: map[string]interface{}{"words": []string{"P", "R", "A", "M", "U", "K", "A"}, "correct_order": []string{"P", "R", "A", "M", "U", "K", "A"}}, XP: baseXP + 1, Order: 4},
			{ID: levelID + "_q5", LevelID: levelID, Type: "input", Question: "Dalam Sandi Kotak 1, sebuah kotak tanpa titik di kiri atas melambangkan huruf pertama abjad. Huruf apakah itu?", Payload: map[string]interface{}{"correct_answer": "A"}, XP: baseXP, Order: 5},
		}
	}

	return qs
}

func writeSQLFiles(questions []Question) {
	upPath := "../../migrations/000005_seed_all_sections.up.sql"
	downPath := "../../migrations/000005_seed_all_sections.down.sql"

	err := os.MkdirAll("../../migrations", 0755)
	if err != nil {
		log.Fatalf("Failed to create dir: %v", err)
	}

	fUp, err := os.Create(upPath)
	if err != nil {
		log.Fatalf("Failed to create up file: %v", err)
	}
	defer fUp.Close()

	fDown, err := os.Create(downPath)
	if err != nil {
		log.Fatalf("Failed to create down file: %v", err)
	}
	defer fDown.Close()

	fmt.Fprintln(fUp, "-- SEED INTERACTIVE DUOLINGO-STYLE QUESTIONS FOR ALL SECTIONS (AUTO-GENERATED)")
	fmt.Fprintln(fUp, "")
	
	fmt.Fprintln(fDown, "-- REVERT INTERACTIVE QUESTIONS")
	fmt.Fprintln(fDown, "")

	for _, q := range questions {
		payloadBytes, _ := json.Marshal(q.Payload)
		payloadStr := string(payloadBytes)
		
		// Escape single quotes in question text and payload
		escapedQuestion := strings.ReplaceAll(q.Question, "'", "''")
		escapedPayload := strings.ReplaceAll(payloadStr, "'", "''")
		
		// Write UP
		fmt.Fprintf(fUp, "INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES ('%s', '%s', '%s', '%s', '%s', %d, %d) ON CONFLICT(id) DO UPDATE SET type = EXCLUDED.type, question = EXCLUDED.question, payload = EXCLUDED.payload, ord = EXCLUDED.ord;\n", 
			q.ID, q.LevelID, q.Type, escapedQuestion, escapedPayload, q.XP, q.Order)
			
		// Write DOWN
		fmt.Fprintf(fDown, "DELETE FROM training_questions WHERE id = '%s';\n", q.ID)
	}
	
	log.Printf("Successfully generated 000005 migrations with %d questions.", len(questions))
}
