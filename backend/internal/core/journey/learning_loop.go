package journey

import (
	"time"

	"github.com/pradigi/backend/internal/core/competency"
	"github.com/pradigi/backend/internal/core/diagnosis"
	"github.com/pradigi/backend/internal/core/evidence"
)

// CompetencyDelta represents the change in a single concept's mastery
// after a learning node is completed. This is what the user sees.
type CompetencyDelta struct {
	ConceptID string  `json:"concept_id"`
	Before    float64 `json:"before"`
	After     float64 `json:"after"`
	Change    float64 `json:"change"` // positive = growth
}

// NodeCompletionResult is returned to Flutter after a journey node is completed.
// It contains the evidence trail and the competency impact.
type NodeCompletionResult struct {
	EvidenceID       string                   `json:"evidence_id"`
	DiagnosisStatus  string                   `json:"diagnosis_status"` // "passed", "struggling", "failed"
	Gaps             []diagnosis.KnowledgeGap `json:"gaps,omitempty"`
	CompetencyDeltas []CompetencyDelta        `json:"competency_deltas"`
	NewReadiness     float64                  `json:"new_readiness"`
	Timestamp        time.Time                `json:"timestamp"`
}

// LearningLoop orchestrates the closed-loop pipeline:
// Mission Finished → Evidence → Diagnosis → Competency Update → Passport
type LearningLoop struct {
	diagnosisEngine  *diagnosis.Engine
	competencyEngine *competency.Engine
}

func NewLearningLoop(
	diagEngine *diagnosis.Engine,
	compEngine *competency.Engine,
) *LearningLoop {
	return &LearningLoop{
		diagnosisEngine:  diagEngine,
		competencyEngine: compEngine,
	}
}

// CompleteNode processes the end of a learning node (e.g., mission completion).
// This is the CRITICAL PATH that proves the entire engine works.
func (ll *LearningLoop) CompleteNode(userID string, nodeID string, missionPassed bool) (*NodeCompletionResult, error) {
	// ─────────────────────────────────────────
	// Step 1: Capture BEFORE state
	// ─────────────────────────────────────────
	beforeProj, err := ll.competencyEngine.Project(userID)
	if err != nil {
		return nil, err
	}

	// ─────────────────────────────────────────
	// Step 2: Generate Evidence Package
	// ─────────────────────────────────────────
	evidencePkg := &evidence.EvidencePackage{
		ID:                 "ev_" + nodeID + "_" + time.Now().Format("20060102150405"),
		JourneyID:          "journey_" + userID,
		NodeID:             nodeID,
		MissionFingerprint: nodeID,
		CreatedAt:          time.Now(),
	}

	if missionPassed {
		evidencePkg.LearningObjectivesAchieved = []string{"lo_array_traversal"}
	}

	// ─────────────────────────────────────────
	// Step 3: Run Diagnosis Engine
	// ─────────────────────────────────────────
	diagResult := ll.diagnosisEngine.Diagnose(evidencePkg)

	// Override diagnosis status based on actual mission outcome
	if missionPassed {
		diagResult.OverallStatus = "passed"
		diagResult.Gaps = nil
	}

	// ─────────────────────────────────────────
	// Step 4: Update Competency Engine
	// ─────────────────────────────────────────
	if err := ll.competencyEngine.UpdateFromDiagnosis(userID, diagResult); err != nil {
		return nil, err
	}

	// ─────────────────────────────────────────
	// Step 5: Project AFTER state
	// ─────────────────────────────────────────
	afterProj, err := ll.competencyEngine.Project(userID)
	if err != nil {
		return nil, err
	}

	// ─────────────────────────────────────────
	// Step 6: Compute Deltas
	// ─────────────────────────────────────────
	deltas := computeDeltas(beforeProj, afterProj)

	return &NodeCompletionResult{
		EvidenceID:       evidencePkg.ID,
		DiagnosisStatus:  diagResult.OverallStatus,
		Gaps:             diagResult.Gaps,
		CompetencyDeltas: deltas,
		NewReadiness:     afterProj.EstimatedReadiness,
		Timestamp:        time.Now(),
	}, nil
}

func computeDeltas(before, after *competency.CompetencyProjection) []CompetencyDelta {
	var deltas []CompetencyDelta

	for conceptID, afterState := range after.Concepts {
		beforeMean := 0.0
		if beforeState, ok := before.Concepts[conceptID]; ok {
			beforeMean = beforeState.Application.Mean
		}
		afterMean := afterState.Application.Mean
		change := afterMean - beforeMean

		deltas = append(deltas, CompetencyDelta{
			ConceptID: conceptID,
			Before:    beforeMean,
			After:     afterMean,
			Change:    change,
		})
	}

	return deltas
}
