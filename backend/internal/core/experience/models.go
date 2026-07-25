package experience

// Component represents a specific UI element (e.g., Markdown, Diagram, Animation, Editor, Terminal).
// It does NOT contain styling properties (color, padding), only content and layout structure.
type Component struct {
	Type    string            `json:"type"`              // e.g., "markdown", "editor", "terminal"
	Content string            `json:"content,omitempty"` // For text-based components
	Data    map[string]string `json:"data,omitempty"`    // Dynamic data bound to the component
}

// Section represents a logical group of components (e.g., a "Notebook" or a "Workbench").
type Section struct {
	Type       string      `json:"type"` // e.g., "notebook", "workbench"
	Title      string      `json:"title"`
	Components []Component `json:"components"`
}

// Scene represents a distinct page/view in the user's journey (e.g., "Introduction", "Mission").
type Scene struct {
	ID       string    `json:"id"`
	Title    string    `json:"title"`
	Sections []Section `json:"sections"`
}

// ExperienceManifest is the final output of the Experience Orchestration Engine (XOE).
// It acts as the Server-Driven UI macro-manifest sent to the Flutter renderer.
type ExperienceManifest struct {
	JourneyID string  `json:"journey_id"`
	Scenes    []Scene `json:"scenes"`
}
