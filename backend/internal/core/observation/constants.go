package observation

type EventName string

const (
	EventObservationSaved      EventName = "observation.saved"
	EventEvidenceExtracted     EventName = "observation.evidence.extracted"
)
