package runtime

import (
	"context"
	"database/sql"
	"errors"
	"log"
)

type Manager struct {
	repo        *Repository
	packRuntime PackRuntime
}

func NewManager(repo *Repository, packRuntime PackRuntime) *Manager {
	return &Manager{
		repo:        repo,
		packRuntime: packRuntime,
	}
}

func (m *Manager) GetCurrentSession(ctx context.Context, userID string) (*RuntimeSession, *PackNode, error) {
	session, err := m.repo.GetActiveSession(ctx, userID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			// Auto-initialize default session if user doesn't have one active yet
			defaultSession, initErr := m.InitializeSession(ctx, userID, "goal_backend_engineer", "cyber_fundamentals", "1.0.0", "mission_log_analysis")
			if initErr != nil {
				log.Printf("⚠️ Auto-initialize session error for %s: %v", userID, initErr)
				return nil, nil, nil
			}
			node, _ := m.packRuntime.GetNode(ctx, "mission_log_analysis")
			return defaultSession, node, nil
		}
		return nil, nil, err
	}

	nodeID := "mission_log_analysis"
	if session.CurrentNodeID != nil && *session.CurrentNodeID != "" {
		nodeID = *session.CurrentNodeID
	}

	node, err := m.packRuntime.GetNode(ctx, nodeID)
	if err != nil {
		return session, nil, err
	}

	return session, node, nil
}

func (m *Manager) InitializeSession(ctx context.Context, userID, goalID, packID, packVersion, startNodeID string) (*RuntimeSession, error) {
	session := &RuntimeSession{
		UserID:             userID,
		LearningGoalID:     &goalID,
		PackID:             &packID,
		PackVersion:        &packVersion,
		CurrentNodeID:      &startNodeID,
		Status:             "NOT_STARTED",
		ProgressPercentage: 0,
	}

	err := m.repo.CreateSession(ctx, session)
	if err != nil {
		return nil, err
	}

	return session, nil
}

func (m *Manager) StartOrUpdateSession(ctx context.Context, userID, goalID, packID, packVersion, startNodeID string) (*RuntimeSession, error) {
	session, err := m.repo.GetActiveSession(ctx, userID)
	if err == nil && session != nil {
		session.CurrentNodeID = &startNodeID
		if packID != "" {
			session.PackID = &packID
		}
		if goalID != "" {
			session.LearningGoalID = &goalID
		}
		session.Status = "RUNNING"
		if updateErr := m.repo.UpdateSession(ctx, session); updateErr != nil {
			log.Printf("❌ [START_OR_UPDATE_SESSION] UpdateSession failed for user %s: %v", userID, updateErr)
			return nil, updateErr
		}
		log.Printf("✅ [START_OR_UPDATE_SESSION] Updated user %s session to node %s", userID, startNodeID)
		return session, nil
	}
	if goalID == "" {
		goalID = "goal_backend_engineer"
	}
	return m.InitializeSession(ctx, userID, goalID, packID, packVersion, startNodeID)
}

func (m *Manager) AdvanceNode(ctx context.Context, sessionID, nextNodeID string) error {
	// In a full implementation, we'd fetch the session, verify logic, and update.
	return nil
}

func (m *Manager) HandleEvent(ctx context.Context, sessionID, event, data string) error {
	// A real implementation would fetch the session, apply state machine logic, and save.
	// For MVP demo, we increment progress and change status.
	// Note: We can't use GetActiveSession because it queries by userID, so we need a GetSessionByID
	// Wait, we can write a direct UPDATE query here for the demo.

	status := "RUNNING"
	progressIncrement := 0

	switch event {
	case "MISSION_STARTED":
		status = "INITIALIZING"
	case "CODE_EXECUTED":
		status = "EXECUTING"
	case "AI_ANALYZED":
		status = "AI_ANALYZING"
		progressIncrement = 25
	case "NODE_COMPLETED":
		status = "COMPLETED"
		progressIncrement = 50
	}

	query := `
		UPDATE runtime_sessions 
		SET status = $1, 
		    progress_percentage = LEAST(100, progress_percentage + $2),
		    last_activity_at = CURRENT_TIMESTAMP
		WHERE id = $3
	`
	_, err := m.repo.db.ExecContext(ctx, query, status, progressIncrement, sessionID)
	return err
}
