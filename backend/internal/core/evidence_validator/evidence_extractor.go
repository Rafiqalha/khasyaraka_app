package evidence_validator

import "github.com/pradigi/backend/internal/core/evidence"

type EvidenceExtractor struct{}

func NewEvidenceExtractor() *EvidenceExtractor {
	return &EvidenceExtractor{}
}

func (e *EvidenceExtractor) Extract(missionID string, verdict Verdict, diag Diagnostic) []evidence.Evidence {
	var evList []evidence.Evidence

	if verdict == VerdictPassed {
		evList = append(evList, evidence.Evidence{
			ObservationID: missionID,
			EvidenceType:  "COMPETENCY_DEMONSTRATED",
			Direction:     "positive",
			Strength:      1.0,
			Reason:        "Passed all test cases",
		})
		return evList
	}

	// For specific diagnostics, map to granular evidence for the Adaptive Engine
	switch diag {
	case DiagLoopBoundary:
		evList = append(evList, evidence.Evidence{
			ObservationID: missionID,
			EvidenceType:  "MISCONCEPTION",
			Direction:     "negative",
			Strength:      0.8,
			Reason:        "Off-by-one loop boundary detected",
		})
	case DiagSyntax:
		evList = append(evList, evidence.Evidence{
			ObservationID: missionID,
			EvidenceType:  "SYNTAX_STRUGGLE",
			Direction:     "negative",
			Strength:      0.9,
			Reason:        "Compile/Syntax Error",
		})
	default:
		evList = append(evList, evidence.Evidence{
			ObservationID: missionID,
			EvidenceType:  "GENERAL_FAILURE",
			Direction:     "negative",
			Strength:      0.5,
			Reason:        string(verdict),
		})
	}

	return evList
}
