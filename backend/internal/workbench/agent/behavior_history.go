package agent

import "sync"

// ===========================
// Layered Behavior History (Formerly Memory)
//
// Five scopes:
//   1. Ephemeral (per-command, cleared after each response) — AgentMemory interface in agent.go
//   2. MissionBehaviorHistory (per-mission)
//   3. ExperimentBehaviorHistory (per-experiment)
//   4. WorkspaceBehaviorHistory (per-workspace/project)
//   5. GlobalBehaviorHistory (per-user lifetime)
//
// These are for the PLATFORM, not the LLM.
// The Agent can query: "User has failed 6 times" without reading all history.
// ===========================

// MissionBehaviorHistory is scoped to a single Mission Session.
type MissionBehaviorHistory struct {
	mu    sync.RWMutex
	store map[string]any

	HintCount     int      `json:"hint_count"`
	FailureCount  int      `json:"failure_count"`
	HintsGiven    []string `json:"hints_given"`
	ErrorsSeen    []string `json:"errors_seen"`
	FilesModified []string `json:"files_modified"`
}

func NewMissionBehaviorHistory() *MissionBehaviorHistory {
	return &MissionBehaviorHistory{
		store:      make(map[string]any),
		HintsGiven: make([]string, 0),
		ErrorsSeen: make([]string, 0),
	}
}

func (m *MissionBehaviorHistory) RecordHint(hint string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.HintCount++
	m.HintsGiven = append(m.HintsGiven, hint)
}

func (m *MissionBehaviorHistory) RecordFailure(errorMsg string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.FailureCount++
	m.ErrorsSeen = append(m.ErrorsSeen, errorMsg)
}

func (m *MissionBehaviorHistory) RecordFileModified(path string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.FilesModified = append(m.FilesModified, path)
}

func (m *MissionBehaviorHistory) Set(key string, value any) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.store[key] = value
}

func (m *MissionBehaviorHistory) Get(key string) (any, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	v, ok := m.store[key]
	return v, ok
}

// ExperimentBehaviorHistory is scoped to an entire Experiment.
type ExperimentBehaviorHistory struct {
	mu    sync.RWMutex
	store map[string]any

	MissionsAttempted  int            `json:"missions_attempted"`
	MissionsCompleted  int            `json:"missions_completed"`
	TotalAICalls       int            `json:"total_ai_calls"`
	TotalFailures      int            `json:"total_failures"`
	StrategyEvolution  []string       `json:"strategy_evolution"`  // Dominant strategies per mission
	DifficultyProgress map[string]int `json:"difficulty_progress"` // difficulty -> count completed
}

func NewExperimentBehaviorHistory() *ExperimentBehaviorHistory {
	return &ExperimentBehaviorHistory{
		store:              make(map[string]any),
		StrategyEvolution:  make([]string, 0),
		DifficultyProgress: make(map[string]int),
	}
}

func (m *ExperimentBehaviorHistory) RecordMissionAttempt(difficulty string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.MissionsAttempted++
}

func (m *ExperimentBehaviorHistory) RecordMissionComplete(difficulty, dominantStrategy string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.MissionsCompleted++
	m.DifficultyProgress[difficulty]++
	m.StrategyEvolution = append(m.StrategyEvolution, dominantStrategy)
}

func (m *ExperimentBehaviorHistory) RecordAICalls(count int) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.TotalAICalls += count
}

func (m *ExperimentBehaviorHistory) RecordFailures(count int) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.TotalFailures += count
}

func (m *ExperimentBehaviorHistory) Set(key string, value any) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.store[key] = value
}

func (m *ExperimentBehaviorHistory) Get(key string) (any, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	v, ok := m.store[key]
	return v, ok
}

// WorkspaceBehaviorHistory is scoped to a Workspace (e.g. Cyber Scout Workspace).
type WorkspaceBehaviorHistory struct {
	mu    sync.RWMutex
	store map[string]any
	
	TotalExperimentsCompleted int `json:"total_experiments_completed"`
	CommonPitfalls            []string `json:"common_pitfalls"`
}

func NewWorkspaceBehaviorHistory() *WorkspaceBehaviorHistory {
	return &WorkspaceBehaviorHistory{store: make(map[string]any)}
}

func (m *WorkspaceBehaviorHistory) Set(key string, value any) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.store[key] = value
}

func (m *WorkspaceBehaviorHistory) Get(key string) (any, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	v, ok := m.store[key]
	return v, ok
}

// GlobalBehaviorHistory is scoped to the User's lifetime across all academies.
type GlobalBehaviorHistory struct {
	mu    sync.RWMutex
	store map[string]any
	
	DominantLearningStyle string `json:"dominant_learning_style"`
}

func NewGlobalBehaviorHistory() *GlobalBehaviorHistory {
	return &GlobalBehaviorHistory{store: make(map[string]any)}
}

func (m *GlobalBehaviorHistory) Set(key string, value any) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.store[key] = value
}

func (m *GlobalBehaviorHistory) Get(key string) (any, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	v, ok := m.store[key]
	return v, ok
}
