package cognitive

import (
	"fmt"
	"sort"
	"strings"
	"time"

	"github.com/pradigi/backend/internal/pkg/logger"
)

type TrajectoryPoint struct {
	Timestamp      time.Time       `json:"timestamp"`
	EpisodeID      string          `json:"episode_id"`
	Signal         CognitiveSignal `json:"signal"`
	QualityScore   float64         `json:"quality_score"`
	BehavioralNote string          `json:"behavioral_note"`
}

// TrajectoryReport represents the output of the Cognitive Time Machine after replaying historical episodes.
type TrajectoryReport struct {
	ReportID           string             `json:"report_id"`
	TargetCapability   string             `json:"target_capability"`
	TimePoints         []*TrajectoryPoint `json:"time_points"`
	ReasoningEvolution string             `json:"reasoning_evolution"`
	Velocity           float64            `json:"velocity"` // Mastery gain rate per episode
	Summary            string             `json:"summary"`
}

// CognitiveTimeMachine performs temporal replay of learner trajectories to model reasoning evolution.
// BOUNDARY RULE: This is the deepest moat of Pradigi OS; it observes how human reasoning transforms over time.
type CognitiveTimeMachine struct {
	memoryStore *LearningMemoryStore
}

func NewCognitiveTimeMachine(memoryStore *LearningMemoryStore) *CognitiveTimeMachine {
	return &CognitiveTimeMachine{memoryStore: memoryStore}
}

// ReplayTrajectory reconstructs chronological learning progression for a specific capability.
func (tm *CognitiveTimeMachine) ReplayTrajectory(capability string) (*TrajectoryReport, error) {
	records := tm.memoryStore.GetRecordsByCapability(capability)
	if len(records) == 0 {
		return nil, fmt.Errorf("no learning memory records found for capability: %s", capability)
	}

	// Sort chronologically
	sorted := make([]*LearningMemoryRecord, len(records))
	copy(sorted, records)
	sort.Slice(sorted, func(i, j int) bool {
		return sorted[i].Timestamp.Before(sorted[j].Timestamp)
	})

	points := make([]*TrajectoryPoint, len(sorted))
	signals := make([]string, len(sorted))
	var totalScoreGain float64

	for i, rec := range sorted {
		points[i] = &TrajectoryPoint{
			Timestamp:      rec.Timestamp,
			EpisodeID:      rec.EpisodeID,
			Signal:         rec.Signal,
			QualityScore:   rec.QualityScore,
			BehavioralNote: rec.BehavioralNote,
		}
		signals[i] = string(rec.Signal)
		if i > 0 {
			totalScoreGain += (rec.QualityScore - sorted[i-1].QualityScore)
		}
	}

	velocity := 0.0
	if len(sorted) > 1 {
		velocity = totalScoreGain / float64(len(sorted)-1)
	} else {
		velocity = sorted[0].QualityScore
	}

	// Determine Reasoning Evolution
	firstSignal := sorted[0].Signal
	lastSignal := sorted[len(sorted)-1].Signal

	evolution := fmt.Sprintf("Evolved from %s (Episode 1) to %s (Episode %d)", firstSignal, lastSignal, len(sorted))
	if firstSignal == SignalGuessing && lastSignal == SignalMastery {
		evolution = "Breakthrough Progression: Evolved from Trial-and-Error Guessing to High-Confidence Debugging Mastery"
	} else if firstSignal == SignalCopying && lastSignal == SignalMastery {
		evolution = "Autonomy Attained: Transitioned from Copy-Dominant reliance to Independent Original Implementation"
	} else if firstSignal == SignalStruggle && lastSignal == SignalMastery {
		evolution = "Perseverance Mastery: Overcame high debugging struggle to achieve verified execution mastery"
	}

	summary := fmt.Sprintf("Replayed %d chronological time points across %v trajectory. Average velocity: %.3f/ep.",
		len(sorted), strings.Join(signals, " ➔ "), velocity)

	logger.Info().Str("capability", capability).Str("evolution", evolution).Float64("velocity", velocity).Msg("Cognitive Time Machine completed trajectory replay")

	return &TrajectoryReport{
		ReportID:           fmt.Sprintf("rep_replay_%d", time.Now().UnixNano()),
		TargetCapability:   capability,
		TimePoints:         points,
		ReasoningEvolution: evolution,
		Velocity:           velocity,
		Summary:            summary,
	}, nil
}
