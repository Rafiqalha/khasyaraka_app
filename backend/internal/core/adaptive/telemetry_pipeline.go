package adaptive

import (
	"encoding/json"
	"time"
)

// RawTelemetryEvent represents an incoming event from the client.
type RawTelemetryEvent struct {
	ID        string                 `json:"id"`
	Event     string                 `json:"event"`
	SessionID string                 `json:"sessionId"`
	JourneyID string                 `json:"journeyId"`
	NodeID    string                 `json:"nodeId"`
	UserID    string                 `json:"userId"`
	Payload   map[string]interface{} `json:"payload"`
	Timestamp time.Time              `json:"timestamp"`
	Duration  int64                  `json:"durationMs,omitempty"`
}

// TelemetryPipeline orchestrates the transformation of raw events into LearnerModel updates.
type TelemetryPipeline struct {
	// dependencies like repos would go here
}

// ProcessBatch ingests a batch of telemetry events.
func (tp *TelemetryPipeline) ProcessBatch(userID string, events []RawTelemetryEvent, model *LearnerModel) {
	// 1. Feature Extraction: derive intermediate signals
	features := extractFeatures(events)

	// 2. Behavior Signals: map features to BehavioralModel patterns
	updateBehavioralModel(&model.BehavioralModel, features)
}

// ExtractedFeatures holds intermediate metrics calculated from a time-window of events.
type ExtractedFeatures struct {
	HintsRequested  int
	TotalIdleTimeMs int64
	FastSkips       int
	TotalReadTimeMs int64
	ReadEventCount  int
	SyntaxErrors    int
	LogicErrors     int
}

func extractFeatures(events []RawTelemetryEvent) ExtractedFeatures {
	var features ExtractedFeatures
	for _, e := range events {
		switch e.Event {
		case "hintOpened":
			features.HintsRequested++
		case "typingPause":
			if duration, ok := e.Payload["pauseDurationMs"].(float64); ok {
				features.TotalIdleTimeMs += int64(duration)
			}
		case "nodeExited":
			// Simplified fast skip logic
			if e.Duration < 3000 {
				features.FastSkips++
			}
		case "missionFailed":
			if errType, ok := e.Payload["errorType"].(string); ok {
				if errType == "syntax" {
					features.SyntaxErrors++
				} else {
					features.LogicErrors++
				}
			}
		}
	}
	return features
}

func updateBehavioralModel(bm *BehavioralModel, features ExtractedFeatures) {
	// Update Attention
	if features.FastSkips > 0 {
		bm.Attention.RapidSkipping += features.FastSkips
	}

	// Simplify: directly add idle time
	bm.Attention.IdleDuration += float64(features.TotalIdleTimeMs) / 1000.0 // seconds

	// Update Help Seeking
	if features.HintsRequested > 2 {
		bm.HelpSeeking.HintFrequency = 1.0 // High
	} else if features.HintsRequested > 0 {
		bm.HelpSeeking.HintFrequency = 0.5 // Medium
	}

	// Update Mistakes (simplified syntax example)
	if features.SyntaxErrors > 0 {
		if bm.Mistakes == nil {
			bm.Mistakes = make(map[MistakeType]MistakePattern)
		}
		pattern := bm.Mistakes[MistakeSyntax]
		pattern.Count += features.SyntaxErrors
		pattern.LastSeen = time.Now()
		bm.Mistakes[MistakeSyntax] = pattern
	}

	// Update Velocity based on skips and errors
	if features.FastSkips > 2 && features.SyntaxErrors == 0 {
		bm.Velocity = VelocityFast
	} else if features.SyntaxErrors > 3 || features.LogicErrors > 2 {
		bm.Velocity = VelocityStruggling
	} else {
		bm.Velocity = VelocityAverage
	}
}

// ParseRawEvents is a utility to unmarshal standard JSON telemetry batches.
func ParseRawEvents(payload []byte) ([]RawTelemetryEvent, error) {
	var body struct {
		Events []RawTelemetryEvent `json:"events"`
	}
	if err := json.Unmarshal(payload, &body); err != nil {
		return nil, err
	}
	return body.Events, nil
}
