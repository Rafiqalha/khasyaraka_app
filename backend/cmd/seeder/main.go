package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
)

type Section struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Tier        string `json:"tier"`
	Order       int    `json:"order"`
}

type Unit struct {
	ID          string `json:"id"`
	SectionID   string `json:"section_id"`
	Title       string `json:"title"`
	Order       int    `json:"order"`
	TotalLevels int    `json:"total_levels"`
}

type Level struct {
	ID             string      `json:"id"`
	UnitID         string      `json:"unit_id"`
	LevelNumber    int         `json:"level_number"`
	Difficulty     string      `json:"difficulty"`
	TotalQuestions int         `json:"total_questions"`
	MinCorrect     int         `json:"min_correct"`
	XPReward       int         `json:"xp_reward"`
	UnlockRule     interface{} `json:"unlock_rule"`
}

type Question struct {
	ID       string      `json:"id"`
	LevelID  string      `json:"level_id"`
	Type     string      `json:"type"`
	Question string      `json:"question"`
	Payload  interface{} `json:"payload"`
	XP       int         `json:"xp"`
	Order    int         `json:"order"`
}

type CyberModule struct {
	ID             string      `json:"id"`
	Title          string      `json:"title"`
	OriginalTitle  string      `json:"original_title"`
	Difficulty     int         `json:"difficulty"`
	MinReadSeconds int         `json:"min_read_seconds"`
	IntelContent   interface{} `json:"intel_content"`
}

type CyberChallenge struct {
	ID              string      `json:"id"`
	ModuleID        string      `json:"module_id"`
	Level           int         `json:"level"`
	Category        string      `json:"category"`
	Difficulty      int         `json:"difficulty"`
	EncryptedData   interface{} `json:"encrypted_data"`
	DecryptedAnswer string      `json:"decrypted_answer"`
	XPReward        int         `json:"xp_reward"`
}

type SKUPoint struct {
	ID          string      `json:"id"`
	Number      int         `json:"number"`
	Title       string      `json:"title"`
	Description string      `json:"description"`
	Category    string      `json:"category"`
	QuizContent interface{} `json:"quiz_content"`
}

type SKUDoc struct {
	Level  string     `json:"level"`
	Points []SKUPoint `json:"points"`
}

func main() {
	outPath := "../../migrations/000003_seed_app_data.up.sql"
	f, err := os.Create(outPath)
	if err != nil {
		log.Fatalf("Failed to create file: %v", err)
	}
	defer f.Close()

	fmt.Fprintln(f, "-- SEED DATA FROM JSON (AUTO-GENERATED)")
	fmt.Fprintln(f, "")

	// 1. SECTIONS
	b, err := ioutil.ReadFile("../../../scout_os_backend/app/data/section.json")
	if err == nil {
		var sections []Section
		json.Unmarshal(b, &sections)
		for _, s := range sections {
			fmt.Fprintf(f, "INSERT INTO training_sections (id, title, description, tier, ord) VALUES ('%s', '%s', '%s', '%s', %d) ON CONFLICT(id) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, ord = EXCLUDED.ord;\n",
				escapeSQL(s.ID), escapeSQL(s.Title), escapeSQL(s.Description), escapeSQL(s.Tier), s.Order)
		}
	}
	fmt.Fprintln(f, "")

	// 2. UNITS
	b, err = ioutil.ReadFile("../../../scout_os_backend/app/data/units.json")
	if err == nil {
		var units []Unit
		json.Unmarshal(b, &units)
		for _, u := range units {
			fmt.Fprintf(f, "INSERT INTO training_units (id, section_id, title, ord, total_levels) VALUES ('%s', '%s', '%s', %d, %d) ON CONFLICT(id) DO UPDATE SET title = EXCLUDED.title, ord = EXCLUDED.ord, total_levels = EXCLUDED.total_levels;\n",
				escapeSQL(u.ID), escapeSQL(u.SectionID), escapeSQL(u.Title), u.Order, u.TotalLevels)
		}
	}
	fmt.Fprintln(f, "")

	// 3. LEVELS
	b, err = ioutil.ReadFile("../../../scout_os_backend/app/data/levels.json")
	if err == nil {
		var levels []Level
		json.Unmarshal(b, &levels)
		for _, l := range levels {
			ur, _ := json.Marshal(l.UnlockRule)
			fmt.Fprintf(f, "INSERT INTO training_levels (id, unit_id, level_number, difficulty, total_questions, min_correct, xp_reward, unlock_rule) VALUES ('%s', '%s', %d, '%s', %d, %d, %d, '%s') ON CONFLICT(id) DO UPDATE SET difficulty = EXCLUDED.difficulty, total_questions = EXCLUDED.total_questions, min_correct = EXCLUDED.min_correct, xp_reward = EXCLUDED.xp_reward, unlock_rule = EXCLUDED.unlock_rule;\n",
				escapeSQL(l.ID), escapeSQL(l.UnitID), l.LevelNumber, escapeSQL(l.Difficulty), l.TotalQuestions, l.MinCorrect, l.XPReward, escapeSQL(string(ur)))
		}
	}
	fmt.Fprintln(f, "")

	// 4. QUESTIONS
	qBase := "../../../scout_os_backend/app/data/question"
	filepath.Walk(qBase, func(path string, info os.FileInfo, err error) error {
		if !info.IsDir() && strings.HasSuffix(info.Name(), ".json") {
			b, err := ioutil.ReadFile(path)
			if err == nil {
				var questions []Question
				json.Unmarshal(b, &questions)
				for _, q := range questions {
					pl, _ := json.Marshal(q.Payload)
					fmt.Fprintf(f, "INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord) VALUES ('%s', '%s', '%s', '%s', '%s', %d, %d) ON CONFLICT(id) DO UPDATE SET question = EXCLUDED.question, payload = EXCLUDED.payload, xp = EXCLUDED.xp, ord = EXCLUDED.ord;\n",
						escapeSQL(q.ID), escapeSQL(q.LevelID), escapeSQL(q.Type), escapeSQL(q.Question), escapeSQL(string(pl)), q.XP, q.Order)
				}
			}
		}
		return nil
	})
	fmt.Fprintln(f, "")

	// 5. CYBER MODULES
	b, err = ioutil.ReadFile("../../../scout_os_backend/app/data/cyber_modules.json")
	if err == nil {
		var mods []CyberModule
		json.Unmarshal(b, &mods)
		for _, m := range mods {
			ic, _ := json.Marshal(m.IntelContent)
			fmt.Fprintf(f, "INSERT INTO cyber_modules (id, title, original_title, difficulty, min_read_seconds, intel_content) VALUES ('%s', '%s', '%s', %d, %d, '%s') ON CONFLICT(id) DO UPDATE SET title = EXCLUDED.title, intel_content = EXCLUDED.intel_content;\n",
				escapeSQL(m.ID), escapeSQL(m.Title), escapeSQL(m.OriginalTitle), m.Difficulty, m.MinReadSeconds, escapeSQL(string(ic)))
		}
	}
	fmt.Fprintln(f, "")

	// 6. CYBER CHALLENGES
	b, err = ioutil.ReadFile("../../../scout_os_backend/app/data/cyber_challenges.json")
	if err == nil {
		var chs []CyberChallenge
		json.Unmarshal(b, &chs)
		for _, c := range chs {
			ed, _ := json.Marshal(c.EncryptedData)
			fmt.Fprintf(f, "INSERT INTO cyber_challenges (id, module_id, level, category, difficulty, encrypted_data, decrypted_answer, xp_reward) VALUES ('%s', '%s', %d, '%s', %d, '%s', '%s', %d) ON CONFLICT(id) DO UPDATE SET encrypted_data = EXCLUDED.encrypted_data, decrypted_answer = EXCLUDED.decrypted_answer;\n",
				escapeSQL(c.ID), escapeSQL(c.ModuleID), c.Level, escapeSQL(c.Category), c.Difficulty, escapeSQL(string(ed)), escapeSQL(c.DecryptedAnswer), c.XPReward)
		}
	}
	fmt.Fprintln(f, "")

	// 7. SKU
	skuBase := "../../../scout_os_backend/app/data/sku"
	filepath.Walk(skuBase, func(path string, info os.FileInfo, err error) error {
		if !info.IsDir() && strings.HasSuffix(info.Name(), ".json") {
			b, err := ioutil.ReadFile(path)
			if err == nil {
				var doc SKUDoc
				json.Unmarshal(b, &doc)
				for _, p := range doc.Points {
					qc, _ := json.Marshal(p.QuizContent)
					fmt.Fprintf(f, "INSERT INTO sku_points (id, level, number, title, description, category, quiz_content) VALUES ('%s', '%s', %d, '%s', '%s', '%s', '%s') ON CONFLICT(id) DO UPDATE SET title = EXCLUDED.title, quiz_content = EXCLUDED.quiz_content;\n",
						escapeSQL(p.ID), escapeSQL(doc.Level), p.Number, escapeSQL(p.Title), escapeSQL(p.Description), escapeSQL(p.Category), escapeSQL(string(qc)))
				}
			}
		}
		return nil
	})

	// Down script
	d, err := os.Create("../../migrations/000003_seed_app_data.down.sql")
	if err == nil {
		fmt.Fprintln(d, "DELETE FROM sku_points;")
		fmt.Fprintln(d, "DELETE FROM cyber_challenges;")
		fmt.Fprintln(d, "DELETE FROM cyber_modules;")
		fmt.Fprintln(d, "DELETE FROM training_questions;")
		fmt.Fprintln(d, "DELETE FROM training_levels;")
		fmt.Fprintln(d, "DELETE FROM training_units;")
		fmt.Fprintln(d, "DELETE FROM training_sections;")
		d.Close()
	}

	log.Println("SQL generation completed successfully!")
}

func escapeSQL(val string) string {
	return strings.ReplaceAll(val, "'", "''")
}
