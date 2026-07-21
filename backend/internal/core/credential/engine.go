package credential

import (
	"errors"
	"time"

	"github.com/pradigi/backend/internal/core/competency"
)

// Engine is responsible for verifying competency and behavior against the CredentialManifest
// and managing the issuance lifecycle.
type Engine struct {}

func NewEngine() *Engine {
	return &Engine{}
}

// EvaluateEligibility checks if a user's current CompetencyProjection meets the manifest rules.
// If it does, the user is moved to 'StatusEligible' (or the eligible state is returned).
func (e *Engine) EvaluateEligibility(userID string, manifest *CredentialManifest, proj *competency.CompetencyProjection) (bool, error) {
	// 1. Check all required competencies exist in the projection
	for _, reqConcept := range manifest.Requirements.Competencies {
		state, exists := proj.Concepts[reqConcept]
		if !exists {
			return false, nil
		}
		// 2. Check Mastery Mean
		if state.Application.Mean < manifest.Requirements.Mastery.Mean*100 {
			return false, nil
		}
		// 3. Check Confidence Interval (A smaller interval means higher confidence)
		// Assuming manifest.Requirements.Mastery.Confidence represents minimum required certainty.
		// For example, 0.75 means we need the variance to be relatively tight.
		if state.Application.ConfidenceInterval > (1.0-manifest.Requirements.Mastery.Confidence)*50 { // Simplified heuristic
			return false, nil
		}
	}

	// 4. Check Behavior & Evidence (Mocked for now)
	// if evidenceCount < manifest.Requirements.Evidence.Missions { return false }
	
	return true, nil
}

// ProcessClaim is triggered when the user explicitly clicks "Claim Credential".
// It generates the immutable AssessmentSnapshot and transitions the credential to "Issued".
func (e *Engine) ProcessClaim(userID string, credentialID string, proj *competency.CompetencyProjection) (*Credential, error) {
	// 1. Find credential in draft/eligible state (Mocked)
	cred := &Credential{
		ID: credentialID,
		UserID: userID,
		Status: StatusEligible,
	}

	if cred.Status != StatusEligible {
		return nil, errors.New("credential is not eligible for claiming")
	}

	// 2. Build the Assessment Snapshot
	now := time.Now()
	snapshot := &AssessmentSnapshot{
		SnapshotID: "snap_" + now.Format("20060102150405"),
		KnowledgeGraphVersion: "v1.0.0", // from context
		CompetencyState: proj.Concepts,
		Timestamp: now,
	}

	// 3. Issue Credential
	cred.AssessmentSnapshot = snapshot
	cred.Status = StatusIssued
	cred.IssuedAt = &now

	// 4. Save to DB (Skipped for now)

	return cred, nil
}
