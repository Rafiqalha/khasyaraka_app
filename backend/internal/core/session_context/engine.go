package session_context

// Engine orchestrates the normalization of various session signals into a clean SessionContext.
type Engine struct{}

func NewEngine() *Engine {
	return &Engine{}
}

// BuildContext generates a normalized SessionContext.
// In a full implementation, this takes raw inputs (e.g. recent failure counts, time of day, self-reported mood)
// and applies heuristics or AI models to score focus and energy.
func (e *Engine) BuildContext(userID, journeyID string, rawInputs map[string]interface{}) *SessionContext {
	ctx := &SessionContext{
		UserID:           userID,
		JourneyID:        journeyID,
		FocusScore:       80, // Default mock value
		EnergyScore:      80, // Default mock value
		AvailableMinutes: 30, // Default mock value
		Device:           "Desktop",
	}

	if val, ok := rawInputs["focus_score"].(float64); ok {
		ctx.FocusScore = int(val)
	}
	if val, ok := rawInputs["energy_score"].(float64); ok {
		ctx.EnergyScore = int(val)
	}
	if val, ok := rawInputs["available_minutes"].(float64); ok {
		ctx.AvailableMinutes = int(val)
	}
	if val, ok := rawInputs["device"].(string); ok {
		ctx.Device = val
	}

	return ctx
}
