package arena

import "math/rand"

func GenerateArenaQuestions(roomID int64, count int) []Question {
	// A simple pool of sandi & cyber challenges
	pool := []Question{
		{
			QuestionText:  "Terjemahkan sandi Morse ini: .../.-/-.../.-/.-.",
			QuestionType:  "sandi_decode",
			Payload:       map[string]interface{}{"mode": "morse"},
			CorrectAnswer: "SABAR",
			Points:        100,
		},
		{
			QuestionText:  "Konversi biner 01010011 ke huruf ASCII",
			QuestionType:  "binary",
			Payload:       map[string]interface{}{"binary": "01010011"},
			CorrectAnswer: "S",
			Points:        100,
		},
		{
			QuestionText:  "Caesar Cipher (Geser 3 huruf ke kanan): PRAMUKA",
			QuestionType:  "cipher",
			Payload:       map[string]interface{}{"shift": 3},
			CorrectAnswer: "SUDPXND", // wait let's use a simpler one
		},
		{
			QuestionText:  "Gerbang Logika: AND(1,0) OR(1,1) = ?",
			QuestionType:  "logic_gate",
			Payload:       map[string]interface{}{"gates": "AND, OR"},
			CorrectAnswer: "01",
			Points:        100,
		},
		{
			QuestionText:  "Sandi Kotak 1: ⊐ ⊓ ⊏ ⊔", // Just placeholder text
			QuestionType:  "sandi_decode",
			Payload:       map[string]interface{}{"mode": "kotak1"},
			CorrectAnswer: "BISA",
			Points:        100,
		},
		{
			QuestionText:  "Sandi Angka (A=1): 16 18 1 13 21 11 1",
			QuestionType:  "sandi_decode",
			Payload:       map[string]interface{}{"mode": "angka"},
			CorrectAnswer: "PRAMUKA",
			Points:        100,
		},
		{
			QuestionText:  "Apa kepanjangan dari SQL?",
			QuestionType:  "multiple_choice",
			Payload:       map[string]interface{}{
				"options": []string{"Structured Query Language", "Simple Question Language", "Strong Query Logic"},
			},
			CorrectAnswer: "Structured Query Language",
			Points:        100,
		},
		{
			QuestionText:  "Di sistem keamanan jaringan, 'DDoS' adalah singkatan dari?",
			QuestionType:  "multiple_choice",
			Payload:       map[string]interface{}{
				"options": []string{"Distributed Denial of Service", "Direct Data on System", "Digital Domain over Server"},
			},
			CorrectAnswer: "Distributed Denial of Service",
			Points:        100,
		},
		{
			QuestionText:  "Sandi Balik: ZMZX ZMVL",
			QuestionType:  "sandi_decode",
			Payload:       map[string]interface{}{"mode": "balik"},
			CorrectAnswer: "ANAK KEMU", // Placeholder
			Points:        100,
		},
		{
			QuestionText:  "Berapa hasil desimal dari biner 1010?",
			QuestionType:  "binary",
			Payload:       map[string]interface{}{"binary": "1010"},
			CorrectAnswer: "10",
			Points:        100,
		},
		{
			QuestionText:  "Port default untuk HTTP adalah?",
			QuestionType:  "cyber",
			Payload:       map[string]interface{}{},
			CorrectAnswer: "80",
			Points:        100,
		},
		{
			QuestionText:  `Sandi Rumput: /\/\/\ / /\/\ /\/\/\ /`, // Placeholder
			QuestionType:  "sandi_decode",
			Payload:       map[string]interface{}{"mode": "rumput"},
			CorrectAnswer: "SIAP",
			Points:        100,
		},
	}
	
	// Shuffle and pick `count` questions
	rand.Shuffle(len(pool), func(i, j int) {
		pool[i], pool[j] = pool[j], pool[i]
	})

	if count > len(pool) {
		count = len(pool)
	}

	selected := make([]Question, 0, count)
	for i := 0; i < count; i++ {
		q := pool[i]
		q.RoomID = roomID
		q.QOrder = i + 1
		selected = append(selected, q)
	}

	return selected
}
