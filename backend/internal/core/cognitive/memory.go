package cognitive

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// LearningMemoryRecord represents the historical narrative of HOW a learner acquired a capability.
// BOUNDARY RULE: Graph stores WHAT is known; Learning Memory stores the qualitative and behavioral WHY and HOW.
type LearningMemoryRecord struct {
	RecordID          string          `json:"record_id"`
	SessionID         string          `json:"session_id"`
	EpisodeID         string          `json:"episode_id"`
	TargetCapability  string          `json:"target_capability"`
	Timestamp         time.Time       `json:"timestamp"`
	DurationSeconds   float64         `json:"duration_seconds"`
	Signal            CognitiveSignal `json:"signal"`
	QualityScore      float64         `json:"quality_score"`
	ReflectionSummary string          `json:"reflection_summary"`
	BehavioralNote    string          `json:"behavioral_note"`
}

const (
	EventLearningMemoryRecorded = "LearningMemoryRecorded"
)

// LearningMemoryStore manages the chronological cognitive narrative of the user.
type LearningMemoryStore struct {
	records map[string][]*LearningMemoryRecord // Keyed by TargetCapability
	bus     kernel.EventBus
	mu      sync.RWMutex
}

func NewLearningMemoryStore(bus kernel.EventBus) *LearningMemoryStore {
	return &LearningMemoryStore{
		records: make(map[string][]*LearningMemoryRecord),
		bus:     bus,
	}
}

// OnEvent subscribes to EventEvidenceValidated from EvidenceValidator.
func (m *LearningMemoryStore) OnEvent(ctx context.Context, event kernel.Event) error {
	if event.Type != EventEvidenceValidated && event.Type != EventEvidenceRejected {
		return nil
	}

	var evd ValidatedEvidence
	if err := json.Unmarshal(event.Payload, &evd); err != nil {
		return fmt.Errorf("failed to unmarshal ValidatedEvidence in LearningMemoryStore: %w", err)
	}

	logger.Info().Str("session", evd.SessionID).Str("capability", evd.TargetCapability).Msg("Learning Memory recording cognitive narrative episode")

	record := &LearningMemoryRecord{
		RecordID:         fmt.Sprintf("mem_%d", time.Now().UnixNano()),
		SessionID:        evd.SessionID,
		EpisodeID:        evd.EpisodeID,
		TargetCapability: evd.TargetCapability,
		Timestamp:        time.Now(),
		Signal:           evd.Signal,
		QualityScore:     evd.QualityScore,
		BehavioralNote:   evd.Reason,
	}

	m.mu.Lock()
	m.records[evd.TargetCapability] = append(m.records[evd.TargetCapability], record)
	m.mu.Unlock()

	if m.bus != nil {
		payloadBytes, _ := json.Marshal(record)
		busEvent := kernel.Event{
			ID:        fmt.Sprintf("evt_mem_%d", time.Now().UnixNano()),
			SessionID: evd.SessionID,
			Type:      EventLearningMemoryRecorded,
			Source:    "learning_memory_store",
			Timestamp: time.Now(),
			Payload:   payloadBytes,
		}
		return m.bus.Publish(ctx, busEvent)
	}
	return nil
}

func (m *LearningMemoryStore) GetRecordsByCapability(capability string) []*LearningMemoryRecord {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.records[capability]
}
