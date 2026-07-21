package capability

type EvaluationEvent struct {
	UserID     string
	SourceType string
	SourceID   string
	Data       interface{}
}

type Feature struct {
	SkillID   string
	Intensity float64 // How strongly this feature was exhibited (0.0 to 1.0)
	Context   string
}

type CapabilityUpdate struct {
	SkillID    string
	DeltaScore int
	Summary    string
}

// FeatureExtractor analyzes an event (e.g., Mission Completed) and extracts observable features.
type FeatureExtractor interface {
	Extract(event EvaluationEvent) ([]Feature, error)
}

// Evaluator converts extracted features into capability updates.
// This interface allows swapping AI models (Gemini, DeepSeek) or Rule Engines.
type Evaluator interface {
	Evaluate(features []Feature, current []LearnerCapability) ([]CapabilityUpdate, error)
}
