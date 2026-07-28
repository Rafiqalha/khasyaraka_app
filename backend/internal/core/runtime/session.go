package runtime

import (
	"fmt"
	"sync"
	"time"

	"github.com/pradigi/backend/internal/core/ai_gateway"
	"github.com/pradigi/backend/internal/core/cognitive"
	"github.com/pradigi/backend/internal/pkg/logger"
)

type QueueState string

const (
	QueueStateQueued     QueueState = "QUEUED"
	QueueStateReady      QueueState = "READY"
	QueueStateActive     QueueState = "ACTIVE"
	QueueStateBlocked    QueueState = "BLOCKED"
	QueueStateReflecting QueueState = "REFLECTING"
	QueueStateValidating QueueState = "VALIDATING"
	QueueStateCompleted  QueueState = "COMPLETED"
	QueueStateArchived   QueueState = "ARCHIVED"
)

type MissionQueueItem struct {
	MissionID  string     `json:"mission_id"`
	Title      string     `json:"title"`
	State      QueueState `json:"state"`
	Difficulty float64    `json:"difficulty"`
	Priority   int        `json:"priority"`
}

// RuntimeSession represents the complete living world of the learner in the OS.
// BOUNDARY RULE: All state (queue, episodes, telemetry, evidence, snapshots) lives in RuntimeSession.
type RuntimeSession struct {
	ID                 string                             `db:"id" json:"id"`
	UserID             string                             `db:"user_id" json:"user_id"`
	EnrollmentID       *string                            `db:"enrollment_id" json:"enrollment_id,omitempty"`
	LearningGoalID     *string                            `db:"learning_goal_id" json:"learning_goal_id,omitempty"`
	PackID             *string                            `db:"pack_id" json:"pack_id,omitempty"`
	PackVersion        *string                            `db:"pack_version" json:"pack_version,omitempty"`
	CurrentNodeID      *string                            `db:"current_node_id" json:"current_node_id,omitempty"`
	Status             string                             `db:"status" json:"status"`
	ProgressPercentage int                                `db:"progress_percentage" json:"progress_percentage"`
	StartedAt          time.Time                          `db:"started_at" json:"started_at"`
	LastActivityAt     time.Time                          `db:"last_activity_at" json:"last_activity_at"`
	CompletedAt        *time.Time                         `db:"completed_at" json:"completed_at,omitempty"`
	Metadata           *string                            `db:"metadata" json:"metadata,omitempty"`
	// SPRINT 4 Upgrade: In-memory OS scheduler queue and cognitive streams
	MissionQueue       []*MissionQueueItem                `db:"-" json:"mission_queue,omitempty"`
	CurrentMission     *ai_gateway.RichMissionInstance    `db:"-" json:"current_mission,omitempty"`
	CurrentEpisode     *cognitive.CognitiveEpisode        `db:"-" json:"current_episode,omitempty"`
	WorkspaceManifest  *WorkspaceManifest                 `db:"-" json:"workspace_manifest,omitempty"`
	TelemetryBuffer    []*cognitive.TelemetryEvent        `db:"-" json:"telemetry_buffer,omitempty"`
	EvidenceStream     []*cognitive.ValidatedEvidence     `db:"-" json:"evidence_stream,omitempty"`
	CapabilitySnapshot map[string]float64                 `db:"-" json:"capability_snapshot,omitempty"`
	KnowledgeSnapshot  map[string]float64                 `db:"-" json:"knowledge_snapshot,omitempty"`
	mu                 sync.RWMutex                       `db:"-" json:"-"`
}

func NewRuntimeSession(sessionID, userID string) *RuntimeSession {
	return &RuntimeSession{
		ID:                 sessionID,
		UserID:             userID,
		Status:             "RUNNING",
		StartedAt:          time.Now(),
		LastActivityAt:     time.Now(),
		MissionQueue:       make([]*MissionQueueItem, 0),
		TelemetryBuffer:    make([]*cognitive.TelemetryEvent, 0),
		EvidenceStream:     make([]*cognitive.ValidatedEvidence, 0),
		CapabilitySnapshot: make(map[string]float64),
		KnowledgeSnapshot:  make(map[string]float64),
	}
}

func (s *RuntimeSession) EnqueueMission(item *MissionQueueItem) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.MissionQueue = append(s.MissionQueue, item)
	logger.Info().Str("session", s.ID).Str("mission", item.MissionID).Str("state", string(item.State)).Msg("Mission enqueued to Runtime Session Queue")
}

func (s *RuntimeSession) TransitionQueueItem(missionID string, newState QueueState) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, item := range s.MissionQueue {
		if item.MissionID == missionID {
			oldState := item.State
			item.State = newState
			logger.Info().Str("session", s.ID).Str("mission", missionID).Str("from", string(oldState)).Str("to", string(newState)).Msg("Mission Queue State Transition")
			return nil
		}
	}
	return fmt.Errorf("mission not found in queue: %s", missionID)
}

func (s *RuntimeSession) BufferTelemetry(event *cognitive.TelemetryEvent) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.TelemetryBuffer = append(s.TelemetryBuffer, event)
}

func (s *RuntimeSession) RecordEvidence(evidence *cognitive.ValidatedEvidence) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.EvidenceStream = append(s.EvidenceStream, evidence)
	logger.Info().Str("session", s.ID).Str("evidence", evidence.EvidenceID).Str("signal", string(evidence.Signal)).Msg("Validated evidence appended to session stream")
}
