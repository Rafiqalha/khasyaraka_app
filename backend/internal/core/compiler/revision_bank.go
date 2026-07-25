package compiler

import (
	"fmt"
	"sync"
	"time"

	"github.com/pradigi/backend/internal/core/catalog"
	"github.com/pradigi/backend/internal/core/telemetry"
)

// MissionRevision - Pedagogical variation of a MissionConcept
type MissionRevision struct {
	ID           string                  `json:"id"`
	ConceptID    string                  `json:"concept_id"`
	RevisionNum  int                     `json:"revision_num"`
	Pedagogy     string                  `json:"pedagogy"` // exploration, guided, visual, debugging, real_world
	Difficulty   string                  `json:"difficulty"`
	Title        string                  `json:"title"`
	Objective    string                  `json:"objective"`
	Instructions string                  `json:"instructions"`
	TemplateCode string                  `json:"template_code"`
	Validator    map[string]any          `json:"validator"`
	CreatedAt    time.Time               `json:"created_at"`
}

// RevisionBank - Thread-safe cache storing pre-generated MissionRevisions
type RevisionBank struct {
	mu        sync.RWMutex
	revisions map[string][]*MissionRevision // ConceptID -> []MissionRevision
}

func NewRevisionBank() *RevisionBank {
	bank := &RevisionBank{
		revisions: make(map[string][]*MissionRevision),
	}
	bank.seedDefaultRevisions()
	return bank
}

func (b *RevisionBank) SelectRevision(conceptID string, diag *telemetry.LearningDiagnosis, retryCount int) (*MissionRevision, bool) {
	b.mu.RLock()
	defer b.mu.RUnlock()

	revs, ok := b.revisions[conceptID]
	if !ok || len(revs) == 0 {
		return nil, false
	}

	targetPedagogy := "guided"
	if diag != nil && diag.Recommendation != "" {
		targetPedagogy = diag.Recommendation
	} else {
		switch retryCount {
		case 0:
			targetPedagogy = "exploration"
		case 1:
			targetPedagogy = "guided"
		case 2:
			targetPedagogy = "visual"
		case 3:
			targetPedagogy = "debugging"
		default:
			targetPedagogy = "real_world"
		}
	}

	for _, r := range revs {
		if r.Pedagogy == targetPedagogy {
			return r, true
		}
	}

	// Fallback to round-robin index based on retryCount
	idx := retryCount % len(revs)
	return revs[idx], true
}

func (b *RevisionBank) AddRevision(conceptID string, rev *MissionRevision) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.revisions[conceptID] = append(b.revisions[conceptID], rev)
}

func (b *RevisionBank) seedDefaultRevisions() {
	// Seed Array Concept Revisions
	b.revisions["python.array"] = []*MissionRevision{
		{
			ID:          "rev_array_exp",
			ConceptID:   "python.array",
			RevisionNum: 1,
			Pedagogy:    "exploration",
			Difficulty:  "normal",
			Title:       "Array Fundamentals: Fruit Inventory",
			Objective:   "Store fruit names in a list and print the second item.",
			Instructions: "Create a list `fruits = ['apple', 'banana', 'cherry']` and print fruits[1].",
			TemplateCode: "fruits = ['apple', 'banana', 'cherry']\nprint(fruits[1])\n",
		},
		{
			ID:          "rev_array_guided",
			ConceptID:   "python.array",
			RevisionNum: 2,
			Pedagogy:    "guided",
			Difficulty:  "easy",
			Title:       "Guided Array: Student Grades List",
			Objective:   "Store student scores in a list and calculate the average score.",
			Instructions: "Calculate average: `avg = sum(scores) / len(scores)`.",
			TemplateCode: "scores = [85, 90, 78, 92]\navg = sum(scores) / len(scores)\nprint(f'Average: {avg:.1f}')\n",
		},
		{
			ID:          "rev_array_visual",
			ConceptID:   "python.array",
			RevisionNum: 3,
			Pedagogy:    "visual",
			Difficulty:  "easier",
			Title:       "Visual Array Indexing Step-by-Step",
			Objective:   "Understand 0-based indexing using visual comments.",
			Instructions: "Access first element (index 0) and last element (index -1).",
			TemplateCode: "# Index: [  0  ,   1  ,   2  ]\nitems = ['first', 'second', 'third']\nprint(items[0])\nprint(items[-1])\n",
		},
	}
}

// ConvertToMissionBlueprint converts a MissionRevision into a MissionBlueprint
func (r *MissionRevision) ToMissionBlueprint() *catalog.MissionBlueprint {
	return &catalog.MissionBlueprint{
		ID:            fmt.Sprintf("%s_rev%d", r.ConceptID, r.RevisionNum),
		Title:         r.Title,
		Type:          "notebook",
		Objective:     r.Objective,
		Instructions:  r.Instructions,
		Difficulty:    r.Difficulty,
		EstimatedSecs: 900,
		IsRequired:    true,
		CompetencyKeys: []string{r.ConceptID},
		Validator:     r.Validator,
	}
}
