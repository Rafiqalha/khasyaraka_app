package adaptive

import "time"

// LearnerModel is the central state for a user's learning journey, separating
// their cognitive understanding from their behavioral patterns.
type LearnerModel struct {
	UserID          string          `json:"user_id"`
	CognitiveModel  CognitiveModel  `json:"cognitive_model"`
	BehavioralModel BehavioralModel `json:"behavioral_model"`
	LearningHistory LearningHistory `json:"learning_history"`
	SessionContext  SessionContext  `json:"session_context"`
}

// CognitiveModel tracks what the user knows and how well they know it.
type CognitiveModel struct {
	Knowledge    KnowledgeState             `json:"knowledge"`
	Competencies map[string]CompetencyState `json:"competencies"` // skillId -> state
	Confidence   ConfidenceScore            `json:"confidence"`
}

type KnowledgeState struct {
	// Represents overall mastery or progression metrics
	OverallMastery float64 `json:"overall_mastery"`
}

type CompetencyState struct {
	Level       float64   `json:"level"`
	Confidence  float64   `json:"confidence"`
	LastUpdated time.Time `json:"last_updated"`
}

type ConfidenceScore struct {
	Score float64 `json:"score"`
}

// BehavioralModel tracks how the user interacts with the platform.
type BehavioralModel struct {
	Attention   AttentionPattern               `json:"attention"`
	Persistence PersistenceMetrics             `json:"persistence"`
	HelpSeeking HelpSeekingMetrics             `json:"help_seeking"`
	Velocity    LearningVelocity               `json:"velocity"`
	Mistakes    map[MistakeType]MistakePattern `json:"mistakes"`
}

type AttentionPattern struct {
	AverageReadTime     float64 `json:"average_read_time"`
	IdleDuration        float64 `json:"idle_duration"`
	RapidSkipping       int     `json:"rapid_skipping"`
	NotebookScrollDepth float64 `json:"notebook_scroll_depth"`
	TabSwitchCount      int     `json:"tab_switch_count"`
	FocusLossEvents     int     `json:"focus_loss_events"`
	HintOpenLatency     float64 `json:"hint_open_latency"`
	RevealCodeLatency   float64 `json:"reveal_code_latency"`
}

type PersistenceMetrics struct {
	RetryRate float64 `json:"retry_rate"`
}

type HelpSeekingMetrics struct {
	HintFrequency float64 `json:"hint_frequency"`
}

type LearningVelocity string

const (
	VelocityFast       LearningVelocity = "FAST"
	VelocityAverage    LearningVelocity = "AVERAGE"
	VelocityStruggling LearningVelocity = "STRUGGLING"
)

type MistakeType string

const (
	MistakeOffByOne           MistakeType = "OffByOne"
	MistakeNullHandling       MistakeType = "NullHandling"
	MistakeLoopBoundary       MistakeType = "LoopBoundary"
	MistakeInfiniteLoop       MistakeType = "InfiniteLoop"
	MistakeWrongVariable      MistakeType = "WrongVariable"
	MistakeWrongOperator      MistakeType = "WrongOperator"
	MistakeMissingReturn      MistakeType = "MissingReturn"
	MistakeIncorrectCondition MistakeType = "IncorrectCondition"
	MistakeSyntax             MistakeType = "Syntax"
	MistakeRuntime            MistakeType = "Runtime"
	MistakeLogic              MistakeType = "Logic"
)

type MistakePattern struct {
	Count      int       `json:"count"`
	Frequency  float64   `json:"frequency"`
	LastSeen   time.Time `json:"last_seen"`
	Confidence float64   `json:"confidence"`
}

type LearningHistory struct {
	CompletedNodes []string `json:"completed_nodes"`
}

type SessionContext struct {
	CurrentNodeID string `json:"current_node_id"`
}
