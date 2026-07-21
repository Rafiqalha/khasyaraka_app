package memory

import (
	"math"
	"time"
)

type MemoryState string

const (
	StateWorking   MemoryState = "WORKING"
	StateShortTerm MemoryState = "SHORT_TERM"
	StateLongTerm  MemoryState = "LONG_TERM"
	StateExpired   MemoryState = "EXPIRED"
)

type DecayEngine struct {}

func NewDecayEngine() *DecayEngine {
	return &DecayEngine{}
}

// CalculateRetention uses Ebbinghaus Forgetting Curve formula: R = e^(-t/S)
// t is time in days since last projection/review
// S is strength of memory
func (d *DecayEngine) CalculateRetention(lastReview time.Time, strength float64) float64 {
	if strength <= 0 {
		return 0
	}
	
	t := time.Since(lastReview).Hours() / 24.0
	// To prevent immediate drop-off if reviewed just now, if t is very small, R ~ 1.0
	retention := math.Exp(-t / strength)
	return retention
}

// DetermineState transitions the memory state based on retention score
func (d *DecayEngine) DetermineState(retention float64, currentStrength float64) MemoryState {
	if retention > 0.8 && currentStrength > 5.0 {
		return StateLongTerm
	}
	if retention > 0.5 {
		return StateShortTerm
	}
	if retention > 0.2 {
		return StateWorking
	}
	return StateExpired
}
