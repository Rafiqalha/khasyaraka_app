package events

const (
	// Mission Events
	MissionCompleted EventName = "mission.completed"
	MissionStarted   EventName = "mission.started"

	// Capability Events
	CapabilityUpdated EventName = "capability.updated"

	// Workspace Events
	WorkspaceSaved           EventName = "workspace.saved"
	LearningActivityRecorded EventName = "learning.activity.recorded"

	// Session Events
	SessionStarted EventName = "session.started"
	SessionResumed EventName = "session.resumed"
	SessionPaused  EventName = "session.paused"
	SessionEnded   EventName = "session.ended"
	SessionRebuilt EventName = "session.rebuilt"

	// Aggregation Events
	ActivityAggregated EventName = "activity.aggregated"

	// Workspace Events
	WorkspaceArtifactSaved   EventName = "workspace.artifact.saved"
	WorkspaceSnapshotCreated EventName = "workspace.snapshot.created"

	// Roadmap Events

	// Memory Events
	MemoryUpdated EventName = "memory.updated"
)
