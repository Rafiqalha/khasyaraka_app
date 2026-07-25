package session

type SessionStatus string

const (
	StatusActive SessionStatus = "ACTIVE"
	StatusPaused SessionStatus = "PAUSED"
	StatusEnded  SessionStatus = "ENDED"
)

type EventName string

const (
	EventSessionStarted EventName = "session.started"
	EventSessionResumed EventName = "session.resumed"
	EventSessionPaused  EventName = "session.paused"
	EventSessionEnded   EventName = "session.ended"
	EventSessionRebuilt EventName = "session.rebuilt"
)
