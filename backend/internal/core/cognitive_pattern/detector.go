package cognitive_pattern

import (
	"time"

	"github.com/oklog/ulid/v2"
)

// ===========================
// Pattern Detector (The Core Engine)
// Scans a sequence of activity events and extracts deterministic patterns.
// No AI. No LLM. Pure finite rules.
// ===========================

// ActivityEvent is a simplified view of a Learning Activity for pattern detection.
type ActivityEvent struct {
	ID        string         `json:"id"`
	Type      string         `json:"type"`  // "RUN_CODE", "SAVE_FILE", "ASK_MENTOR", "COMPILE", etc.
	Actor     string         `json:"actor"` // "USER", "COMPILER", "MENTOR", "SYSTEM"
	Payload   map[string]any `json:"payload"`
	Timestamp time.Time      `json:"timestamp"`
}

// PatternDetector analyzes sequences of events and extracts cognitive patterns.
type PatternDetector struct {
	rules []DetectionRule
}

// DetectionRule is a single pattern detection rule.
type DetectionRule struct {
	PatternType PatternType
	Detect      func(events []ActivityEvent) []CognitivePattern
}

func NewPatternDetector() *PatternDetector {
	d := &PatternDetector{}
	d.rules = []DetectionRule{
		{PatternRepeatedExecution, d.detectRepeatedExecution},
		{PatternRapidRetry, d.detectRapidRetry},
		{PatternErrorDrivenIteration, d.detectErrorDrivenIteration},
		{PatternHintCopy, d.detectHintCopy},
		{PatternHintIgnored, d.detectHintIgnored},
		{PatternAIDependency, d.detectAIDependency},
		{PatternTrialAndError, d.detectTrialAndError},
		{PatternPersistence, d.detectPersistence},
		{PatternEarlyAbandon, d.detectEarlyAbandon},
		{PatternRecoveryAfterBlock, d.detectRecoveryAfterBlock},
	}
	return d
}

// Detect runs all detection rules against the event sequence.
func (d *PatternDetector) Detect(sessionID string, events []ActivityEvent) *PatternSummary {
	if len(events) == 0 {
		return &PatternSummary{SessionID: sessionID}
	}

	var allPatterns []CognitivePattern
	for _, rule := range d.rules {
		patterns := rule.Detect(events)
		allPatterns = append(allPatterns, patterns...)
	}

	// Calculate summary metrics
	summary := &PatternSummary{
		SessionID:     sessionID,
		Patterns:      allPatterns,
		TotalPatterns: len(allPatterns),
	}

	// Count distinct pattern types
	typeSet := make(map[PatternType]int)
	for _, p := range allPatterns {
		typeSet[p.PatternType] += p.Frequency
	}
	summary.StrategyDiversity = len(typeSet)

	// Find dominant strategy
	maxFreq := 0
	for pt, freq := range typeSet {
		if freq > maxFreq {
			maxFreq = freq
			summary.DominantStrategy = pt
		}
	}

	// AI reliance: ratio of AI events to total events
	aiEvents := 0
	for _, e := range events {
		if e.Type == "ASK_MENTOR" || e.Type == "AgentRequested" {
			aiEvents++
		}
	}
	if len(events) > 0 {
		summary.AIReliance = float64(aiEvents) / float64(len(events))
	}

	// Persistence: ratio of events after first failure to total events
	firstFailIdx := -1
	for i, e := range events {
		if e.Type == "COMPILE_ERROR" || e.Type == "TEST_FAILED" || e.Type == "RUNTIME_ERROR" {
			firstFailIdx = i
			break
		}
	}
	if firstFailIdx >= 0 && len(events) > 0 {
		summary.PersistenceScore = float64(len(events)-firstFailIdx) / float64(len(events))
	}

	return summary
}

// ===========================
// Detection Rules (Deterministic)
// ===========================

func (d *PatternDetector) detectRepeatedExecution(events []ActivityEvent) []CognitivePattern {
	var patterns []CognitivePattern
	streak := 0
	var streakStart time.Time
	var streakIDs []string

	for i, e := range events {
		if e.Type == "RUN_CODE" || e.Type == "ToolExecuted" {
			if streak == 0 {
				streakStart = e.Timestamp
			}
			streak++
			streakIDs = append(streakIDs, e.ID)
		} else {
			if streak >= 3 {
				avgInterval := 0.0
				if streak > 1 {
					avgInterval = events[i-1].Timestamp.Sub(streakStart).Seconds() / float64(streak-1)
				}
				patterns = append(patterns, CognitivePattern{
					ID:              ulid.Make().String(),
					PatternType:     PatternRepeatedExecution,
					SourceEventIDs:  streakIDs,
					Frequency:       streak,
					AverageInterval: avgInterval,
					Confidence:      0.9,
					StartedAt:       streakStart,
					EndedAt:         events[i-1].Timestamp,
				})
			}
			streak = 0
			streakIDs = nil
		}
	}
	// Flush remaining streak
	if streak >= 3 {
		patterns = append(patterns, CognitivePattern{
			ID:             ulid.Make().String(),
			PatternType:    PatternRepeatedExecution,
			Frequency:      streak,
			SourceEventIDs: streakIDs,
			Confidence:     0.9,
			StartedAt:      streakStart,
			EndedAt:        events[len(events)-1].Timestamp,
		})
	}
	return patterns
}

func (d *PatternDetector) detectRapidRetry(events []ActivityEvent) []CognitivePattern {
	var patterns []CognitivePattern
	for i := 1; i < len(events); i++ {
		prev, curr := events[i-1], events[i]
		isRun := (curr.Type == "RUN_CODE" || curr.Type == "ToolExecuted")
		wasFail := (prev.Type == "COMPILE_ERROR" || prev.Type == "TEST_FAILED" || prev.Type == "RUNTIME_ERROR")
		interval := curr.Timestamp.Sub(prev.Timestamp).Seconds()

		if isRun && wasFail && interval < 10 {
			patterns = append(patterns, CognitivePattern{
				ID:              ulid.Make().String(),
				PatternType:     PatternRapidRetry,
				SourceEventIDs:  []string{prev.ID, curr.ID},
				Frequency:       1,
				AverageInterval: interval,
				Confidence:      0.85,
				StartedAt:       prev.Timestamp,
				EndedAt:         curr.Timestamp,
			})
		}
	}
	return patterns
}

func (d *PatternDetector) detectErrorDrivenIteration(events []ActivityEvent) []CognitivePattern {
	var patterns []CognitivePattern
	// Pattern: Error → Edit → Run
	for i := 2; i < len(events); i++ {
		isError := events[i-2].Type == "COMPILE_ERROR" || events[i-2].Type == "RUNTIME_ERROR"
		isEdit := events[i-1].Type == "SAVE_FILE" || events[i-1].Type == "EnvironmentChanged"
		isRun := events[i].Type == "RUN_CODE" || events[i].Type == "ToolExecuted"

		if isError && isEdit && isRun {
			patterns = append(patterns, CognitivePattern{
				ID:             ulid.Make().String(),
				PatternType:    PatternErrorDrivenIteration,
				SourceEventIDs: []string{events[i-2].ID, events[i-1].ID, events[i].ID},
				Frequency:      1,
				Confidence:     0.95,
				StartedAt:      events[i-2].Timestamp,
				EndedAt:        events[i].Timestamp,
			})
		}
	}
	return patterns
}

func (d *PatternDetector) detectHintCopy(events []ActivityEvent) []CognitivePattern {
	var patterns []CognitivePattern
	// Pattern: AskMentor → (AgentResponded) → SaveFile → Run (within short time)
	for i := 3; i < len(events); i++ {
		isAsk := events[i-3].Type == "ASK_MENTOR" || events[i-3].Type == "AgentRequested"
		isResponse := events[i-2].Type == "AgentResponded"
		isSave := events[i-1].Type == "SAVE_FILE" || events[i-1].Type == "EnvironmentChanged"
		isRun := events[i].Type == "RUN_CODE" || events[i].Type == "ToolExecuted"

		if isAsk && isResponse && isSave && isRun {
			interval := events[i].Timestamp.Sub(events[i-3].Timestamp).Seconds()
			if interval < 60 { // Quick copy-paste within 1 minute
				patterns = append(patterns, CognitivePattern{
					ID:              ulid.Make().String(),
					PatternType:     PatternHintCopy,
					SourceEventIDs:  []string{events[i-3].ID, events[i-2].ID, events[i-1].ID, events[i].ID},
					Frequency:       1,
					AverageInterval: interval,
					Confidence:      0.8,
					StartedAt:       events[i-3].Timestamp,
					EndedAt:         events[i].Timestamp,
				})
			}
		}
	}
	return patterns
}

func (d *PatternDetector) detectHintIgnored(events []ActivityEvent) []CognitivePattern {
	var patterns []CognitivePattern
	for i := 2; i < len(events); i++ {
		isResponse := events[i-2].Type == "AgentResponded"
		noEdit := events[i-1].Type != "SAVE_FILE" && events[i-1].Type != "EnvironmentChanged"
		isRun := events[i].Type == "RUN_CODE" || events[i].Type == "ToolExecuted"

		if isResponse && noEdit && isRun {
			patterns = append(patterns, CognitivePattern{
				ID:             ulid.Make().String(),
				PatternType:    PatternHintIgnored,
				SourceEventIDs: []string{events[i-2].ID, events[i-1].ID, events[i].ID},
				Frequency:      1,
				Confidence:     0.75,
				StartedAt:      events[i-2].Timestamp,
				EndedAt:        events[i].Timestamp,
			})
		}
	}
	return patterns
}

func (d *PatternDetector) detectAIDependency(events []ActivityEvent) []CognitivePattern {
	aiCalls := 0
	ownAttempts := 0
	for _, e := range events {
		if e.Type == "ASK_MENTOR" || e.Type == "AgentRequested" {
			aiCalls++
		}
		if e.Type == "RUN_CODE" || e.Type == "ToolExecuted" {
			ownAttempts++
		}
	}

	if ownAttempts > 0 && float64(aiCalls)/float64(ownAttempts) > 0.5 {
		return []CognitivePattern{{
			ID:          ulid.Make().String(),
			PatternType: PatternAIDependency,
			Frequency:   aiCalls,
			Confidence:  float64(aiCalls) / float64(ownAttempts),
			Duration:    events[len(events)-1].Timestamp.Sub(events[0].Timestamp).Seconds(),
			StartedAt:   events[0].Timestamp,
			EndedAt:     events[len(events)-1].Timestamp,
		}}
	}
	return nil
}

func (d *PatternDetector) detectTrialAndError(events []ActivityEvent) []CognitivePattern {
	// Trial and error: Run → Fail → Edit(small) → Run → Fail, without reading error
	runFailCount := 0
	for i := 1; i < len(events); i++ {
		isRun := events[i-1].Type == "RUN_CODE" || events[i-1].Type == "ToolExecuted"
		isFail := events[i].Type == "COMPILE_ERROR" || events[i].Type == "TEST_FAILED"
		if isRun && isFail {
			runFailCount++
		}
	}
	if runFailCount >= 3 {
		return []CognitivePattern{{
			ID:          ulid.Make().String(),
			PatternType: PatternTrialAndError,
			Frequency:   runFailCount,
			Confidence:  0.8,
			StartedAt:   events[0].Timestamp,
			EndedAt:     events[len(events)-1].Timestamp,
		}}
	}
	return nil
}

func (d *PatternDetector) detectPersistence(events []ActivityEvent) []CognitivePattern {
	failCount := 0
	postFailActions := 0
	for _, e := range events {
		if e.Type == "COMPILE_ERROR" || e.Type == "TEST_FAILED" || e.Type == "RUNTIME_ERROR" {
			failCount++
		} else if failCount > 0 {
			postFailActions++
		}
	}
	if failCount >= 3 && postFailActions >= failCount {
		return []CognitivePattern{{
			ID:          ulid.Make().String(),
			PatternType: PatternPersistence,
			Frequency:   postFailActions,
			Confidence:  float64(postFailActions) / float64(postFailActions+failCount),
			StartedAt:   events[0].Timestamp,
			EndedAt:     events[len(events)-1].Timestamp,
		}}
	}
	return nil
}

func (d *PatternDetector) detectEarlyAbandon(events []ActivityEvent) []CognitivePattern {
	if len(events) < 5 {
		lastEvent := events[len(events)-1]
		if lastEvent.Type == "MissionCompleted" {
			payload, _ := lastEvent.Payload["outcome"].(string)
			if payload == "Abandoned" {
				return []CognitivePattern{{
					ID:          ulid.Make().String(),
					PatternType: PatternEarlyAbandon,
					Frequency:   1,
					Confidence:  0.9,
					StartedAt:   events[0].Timestamp,
					EndedAt:     lastEvent.Timestamp,
				}}
			}
		}
	}
	return nil
}

func (d *PatternDetector) detectRecoveryAfterBlock(events []ActivityEvent) []CognitivePattern {
	var patterns []CognitivePattern
	// Pattern: multiple failures → AI call → success
	for i := 2; i < len(events); i++ {
		wasFail := events[i-2].Type == "COMPILE_ERROR" || events[i-2].Type == "TEST_FAILED"
		isAI := events[i-1].Type == "AgentResponded"
		isProgress := events[i].Type == "RUN_CODE" || events[i].Type == "ToolExecuted"

		if wasFail && isAI && isProgress {
			patterns = append(patterns, CognitivePattern{
				ID:             ulid.Make().String(),
				PatternType:    PatternRecoveryAfterBlock,
				SourceEventIDs: []string{events[i-2].ID, events[i-1].ID, events[i].ID},
				Frequency:      1,
				Confidence:     0.85,
				StartedAt:      events[i-2].Timestamp,
				EndedAt:        events[i].Timestamp,
			})
		}
	}
	return patterns
}
