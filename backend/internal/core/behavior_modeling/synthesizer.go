package behavior_modeling

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"sort"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/cognitive_pattern"
)

// ===========================
// Behavior Synthesizer
// Translates deterministic Cognitive Patterns into a stable Behavior Profile.
// Standalone component in the pipeline.
// ===========================

const CurrentSynthesizerVersion = "v1.0.0"

type Synthesizer struct{}

func NewSynthesizer() *Synthesizer {
	return &Synthesizer{}
}

// Synthesize creates a BehaviorProfile for a specific Mission Session.
// baselineProfile is optional. If nil, Baseline dimensions will match Current.
func (s *Synthesizer) Synthesize(
	userID string,
	sessionID string,
	parentProfile *BehaviorProfile,
	baselineProfile *BehaviorProfile,
	patterns []cognitive_pattern.CognitivePattern,
) *BehaviorProfile {

	now := time.Now()

	// 1. Calculate Current Dimensions based on new patterns
	currentPersistence := s.synthesizePersistence(patterns)
	currentAIDependency := s.synthesizeAIDependency(patterns)
	currentRecovery := s.synthesizeRecovery(patterns)
	currentStrategies := s.synthesizeStrategies(patterns)

	// 2. Set up dimensions (comparing against baseline if available)
	profile := &BehaviorProfile{
		ID:                 ulid.Make().String(),
		UserID:             userID,
		SessionID:          sessionID,
		Window:             WindowMission,
		Version:            1,
		SynthesizerVersion: CurrentSynthesizerVersion,
		GeneratedAt:        now,

		Persistence:        BehaviorDimensions{Current: currentPersistence},
		AIDependency:       BehaviorDimensions{Current: currentAIDependency},
		RecoveryCapability: BehaviorDimensions{Current: currentRecovery},
		Strategies:         StrategyDimensions{Current: currentStrategies},
	}

	if parentProfile != nil {
		profile.Version = parentProfile.Version + 1
		profile.ParentProfileID = parentProfile.ID
	}

	if baselineProfile != nil {
		profile.Persistence.Baseline = baselineProfile.Persistence.Current
		profile.AIDependency.Baseline = baselineProfile.AIDependency.Current
		profile.RecoveryCapability.Baseline = baselineProfile.RecoveryCapability.Current
		profile.Strategies.Baseline = baselineProfile.Strategies.Current

		// Calculate Stability (based on how often it changes vs parent)
		if parentProfile != nil {
			profile.Persistence.Current.Stability = s.calculateStability(profile.Persistence.Current.Value, parentProfile.Persistence.Current.Value, parentProfile.Persistence.Current.Stability)
			profile.AIDependency.Current.Stability = s.calculateStability(profile.AIDependency.Current.Value, parentProfile.AIDependency.Current.Value, parentProfile.AIDependency.Current.Stability)
			profile.RecoveryCapability.Current.Stability = s.calculateStability(profile.RecoveryCapability.Current.Value, parentProfile.RecoveryCapability.Current.Value, parentProfile.RecoveryCapability.Current.Stability)
		} else {
			profile.Persistence.Current.Stability = 0.5
			profile.AIDependency.Current.Stability = 0.5
			profile.RecoveryCapability.Current.Stability = 0.5
		}

		// Calculate Diff
		profile.RecentEvolution = &BehaviorDiff{
			PersistenceShift: TraitDiff{
				PreviousValue: profile.Persistence.Baseline.Value,
				CurrentValue:  profile.Persistence.Current.Value,
			},
			AIDependencyShift: TraitDiff{
				PreviousValue: profile.AIDependency.Baseline.Value,
				CurrentValue:  profile.AIDependency.Current.Value,
			},
			// Simplistic strategy diff for top string
			StrategyShift: TraitDiff{
				PreviousValue: "...", // Detailed below
				CurrentValue:  "...",
			},
		}
	} else {
		// If no baseline, current IS the baseline
		profile.Persistence.Baseline = currentPersistence
		profile.AIDependency.Baseline = currentAIDependency
		profile.RecoveryCapability.Baseline = currentRecovery
		profile.Strategies.Baseline = currentStrategies

		profile.Persistence.Current.Stability = 0.5
		profile.AIDependency.Current.Stability = 0.5
		profile.RecoveryCapability.Current.Stability = 0.5
	}

	// 3. Generate Fingerprint for deterministic replay/audit
	profile.Fingerprint = s.generateFingerprint(profile, patterns)

	return profile
}

// GenerateSummary creates the dense payload for the LLM.
func (s *Synthesizer) GenerateSummary(profile *BehaviorProfile) *BehaviorSummary {
	summary := &BehaviorSummary{
		PersistenceLevel:   profile.Persistence.Current.Value,
		AIDependencyLevel:  profile.AIDependency.Current.Value,
		RecoveryCapability: profile.RecoveryCapability.Current.Value,
	}

	// Find primary strategy
	var primary StrategyType
	var maxConf float64 = -1
	for st, prob := range profile.Strategies.Current.Value {
		if prob > maxConf {
			maxConf = prob
			primary = st
		}
	}

	summary.PrimaryStrategy = string(primary)
	summary.StrategyConfidence = maxConf * profile.Strategies.Current.Confidence // Combined confidence

	// Detect anomalies (Current != Baseline)
	if profile.Persistence.Current.Value != profile.Persistence.Baseline.Value {
		summary.AnomalyHighlights = append(summary.AnomalyHighlights,
			fmt.Sprintf("Persistence changed from %s to %s", profile.Persistence.Baseline.Value, profile.Persistence.Current.Value))
	}

	var basePrimary StrategyType
	var baseMaxConf float64 = -1
	for st, prob := range profile.Strategies.Baseline.Value {
		if prob > baseMaxConf {
			baseMaxConf = prob
			basePrimary = st
		}
	}

	if primary != basePrimary {
		summary.AnomalyHighlights = append(summary.AnomalyHighlights,
			fmt.Sprintf("Strategy shifted from %s to %s", basePrimary, primary))
	}

	// LLM Guidance
	if summary.PrimaryStrategy == string(StrategyTrialError) && summary.PersistenceLevel == "Low" {
		summary.LLMContextGuidance = "User is randomly guessing and losing patience. Provide structural scaffolding rather than syntax hints."
	} else if summary.PrimaryStrategy == string(StrategySystematic) {
		summary.LLMContextGuidance = "User is debugging systematically. Keep hints minimal and Socratic to preserve their momentum."
	} else if summary.AIDependencyLevel == "High" {
		summary.LLMContextGuidance = "User relies heavily on AI. Encourage independent hypothesis generation."
	}

	// Narrative
	summary.BehaviorNarrative = fmt.Sprintf("Pengguna menunjukkan pola belajar berbasis %s. Ketika menemui hambatan, kegigihannya %s dan ketergantungan pada AI %s.",
		summary.PrimaryStrategy, summary.PersistenceLevel, summary.AIDependencyLevel)

	return summary
}

func (s *Synthesizer) calculateStability(current string, previous string, previousStability float64) float64 {
	if current == previous {
		// Increases stability, approaching 1.0
		return previousStability + (1.0-previousStability)*0.2
	}
	// Decreases stability
	return previousStability * 0.5
}

// --- Internal Synthesizers ---

func (s *Synthesizer) synthesizePersistence(patterns []cognitive_pattern.CognitivePattern) BehaviorTrait[string] {
	trait := BehaviorTrait[string]{Value: "Medium", Confidence: 0.5} // Default

	var evidence []BehaviorEvidence
	for _, p := range patterns {
		if p.PatternType == cognitive_pattern.PatternPersistence {
			evidence = append(evidence, BehaviorEvidence{
				PatternType:       p.PatternType,
				PatternEpisodeIDs: []string{p.ID},
				Weight:            p.Confidence,
				Description:       "Demonstrated persistence after multiple failures",
			})
			trait.Value = "High"
			trait.Confidence = p.Confidence
		} else if p.PatternType == cognitive_pattern.PatternEarlyAbandon {
			evidence = append(evidence, BehaviorEvidence{
				PatternType:       p.PatternType,
				PatternEpisodeIDs: []string{p.ID},
				Weight:            p.Confidence,
				Description:       "Abandoned mission shortly after starting",
			})
			trait.Value = "Low"
			trait.Confidence = p.Confidence
		}
	}
	trait.Evidence = evidence
	return trait
}

func (s *Synthesizer) synthesizeAIDependency(patterns []cognitive_pattern.CognitivePattern) BehaviorTrait[string] {
	trait := BehaviorTrait[string]{Value: "Low", Confidence: 0.6}
	var evidence []BehaviorEvidence

	for _, p := range patterns {
		if p.PatternType == cognitive_pattern.PatternAIDependency {
			evidence = append(evidence, BehaviorEvidence{
				PatternType:       p.PatternType,
				PatternEpisodeIDs: []string{p.ID},
				Weight:            p.Confidence,
				Description:       fmt.Sprintf("High ratio of AI calls to attempts (confidence: %.2f)", p.Confidence),
			})
			trait.Value = "High"
			trait.Confidence = p.Confidence
		} else if p.PatternType == cognitive_pattern.PatternHintCopy {
			evidence = append(evidence, BehaviorEvidence{
				PatternType:       p.PatternType,
				PatternEpisodeIDs: []string{p.ID},
				Weight:            p.Confidence * 0.5,
				Description:       "Copied hints directly without apparent modification",
			})
			// Multiple hint copies increase dependency
			if len(evidence) > 2 {
				trait.Value = "High"
			}
		}
	}
	trait.Evidence = evidence
	return trait
}

func (s *Synthesizer) synthesizeRecovery(patterns []cognitive_pattern.CognitivePattern) BehaviorTrait[string] {
	trait := BehaviorTrait[string]{Value: "Average", Confidence: 0.5}
	var evidence []BehaviorEvidence

	for _, p := range patterns {
		if p.PatternType == cognitive_pattern.PatternRecoveryAfterBlock {
			evidence = append(evidence, BehaviorEvidence{
				PatternType:       p.PatternType,
				PatternEpisodeIDs: []string{p.ID},
				Weight:            p.Confidence,
				Description:       "Successfully recovered progress after being blocked",
			})
			trait.Value = "Excellent"
			trait.Confidence = p.Confidence
		}
	}
	trait.Evidence = evidence
	return trait
}

func (s *Synthesizer) synthesizeStrategies(patterns []cognitive_pattern.CognitivePattern) BehaviorTrait[StrategyDistribution] {
	dist := make(StrategyDistribution)
	var evidence []BehaviorEvidence

	// Base distributions
	sysWeight := 0.0
	teWeight := 0.0

	for _, p := range patterns {
		switch p.PatternType {
		case cognitive_pattern.PatternSystematicDebugging, cognitive_pattern.PatternErrorDrivenIteration, cognitive_pattern.PatternStackTraceNavigation:
			sysWeight += p.Confidence
			evidence = append(evidence, BehaviorEvidence{
				PatternType:       p.PatternType,
				PatternEpisodeIDs: []string{p.ID},
				Weight:            p.Confidence,
				Description:       "Methodical approach to errors",
			})
		case cognitive_pattern.PatternTrialAndError, cognitive_pattern.PatternRapidRetry, cognitive_pattern.PatternRepeatedExecution:
			teWeight += p.Confidence
			evidence = append(evidence, BehaviorEvidence{
				PatternType:       p.PatternType,
				PatternEpisodeIDs: []string{p.ID},
				Weight:            p.Confidence,
				Description:       "Guess-and-check approach",
			})
		}
	}

	total := sysWeight + teWeight
	if total == 0 {
		dist[StrategySystematic] = 0.5
		dist[StrategyTrialError] = 0.5
		return BehaviorTrait[StrategyDistribution]{Value: dist, Confidence: 0.3, Evidence: nil}
	}

	dist[StrategySystematic] = sysWeight / total
	dist[StrategyTrialError] = teWeight / total

	// Confidence is higher if total evidence weight is high
	conf := total / 5.0
	if conf > 0.9 {
		conf = 0.9
	}

	return BehaviorTrait[StrategyDistribution]{
		Value:      dist,
		Confidence: conf,
		Evidence:   evidence,
	}
}

func (s *Synthesizer) generateFingerprint(profile *BehaviorProfile, patterns []cognitive_pattern.CognitivePattern) string {
	// Simple deterministic hash based on Synthesizer Version + Pattern IDs
	var input string
	input += profile.SynthesizerVersion + "|" + string(profile.Window) + "|"

	var patternIDs []string
	for _, p := range patterns {
		patternIDs = append(patternIDs, p.ID)
	}
	sort.Strings(patternIDs)

	for _, id := range patternIDs {
		input += id + ","
	}

	hash := sha256.Sum256([]byte(input))
	return hex.EncodeToString(hash[:])
}
