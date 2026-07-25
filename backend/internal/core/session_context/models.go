package session_context

// SessionContext represents the normalized learning state before entering a node.
type SessionContext struct {
	ID        string `json:"id"`
	UserID    string `json:"user_id"`
	JourneyID string `json:"journey_id"`

	FocusScore       int    `json:"focus_score"`  // 0-100
	EnergyScore      int    `json:"energy_score"` // 0-100
	AvailableMinutes int    `json:"available_minutes"`
	LearningGoal     string `json:"learning_goal"`

	// Environment
	Device        string `json:"device"`  // Mobile, Tablet, Desktop
	Network       string `json:"network"` // Slow, Fast
	Accessibility bool   `json:"accessibility_mode"`
}
