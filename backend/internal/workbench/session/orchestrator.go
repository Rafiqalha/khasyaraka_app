// Package session — Session Orchestrator.
//
// The Session Orchestrator is the SOLE coordinator of all Workbench activity.
// It receives Commands, delegates to Runtime/Agent/ObjectiveEngine,
// and emits Workbench Events. No other component may emit events.
//
// Flow:
//
//	Command → Session Orchestrator → Runtime.Execute() → ExecutionResult
//	                               → Evaluator.Assess() → ExecutionAssessment
//	                               → ObjectiveEngine.Check() → ObjectiveStatus
//	                               → emit WorkbenchEvent (Learning Activity)
//	                               → update MissionSummary Projection (live)
//	                               → update CognitiveState FSM
//	                               → capture SessionSnapshot
package session

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/workbench/agent"
	"github.com/pradigi/backend/internal/workbench/domain"
	"github.com/pradigi/backend/internal/workbench/engine"
	"github.com/pradigi/backend/internal/workbench/runtime"
)

// Orchestrator is the central coordinator of a Mission Session.
type Orchestrator struct {
	session         *MissionSession
	runtimeRegistry *runtime.Registry
	policy          runtime.ExecutionPolicy
	evaluator       engine.Evaluator
	objectiveEngine *engine.ObjectiveEngine
	cognitiveFSM    *engine.CognitiveStateFSM
	// Agent Engine
	agentFactory  agent.AgentFactory
	roleRegistry  *agent.RoleRegistry
	agents        map[string]agent.Agent // roleID -> active agent instance
	agentMemories map[string]agent.AgentMemory
	// Output channels
	events    []WorkbenchEvent
	snapshots []SessionSnapshot
	projector *StateProjector
}

func NewOrchestrator(
	session *MissionSession,
	registry *runtime.Registry,
	policy runtime.ExecutionPolicy,
	evaluator engine.Evaluator,
	objectiveEngine *engine.ObjectiveEngine,
	agentFactory agent.AgentFactory,
	roleRegistry *agent.RoleRegistry,
) *Orchestrator {
	return &Orchestrator{
		session:         session,
		runtimeRegistry: registry,
		policy:          policy,
		evaluator:       evaluator,
		objectiveEngine: objectiveEngine,
		cognitiveFSM:    engine.NewCognitiveStateFSM(),
		agentFactory:    agentFactory,
		roleRegistry:    roleRegistry,
		agents:          make(map[string]agent.Agent),
		agentMemories:   make(map[string]agent.AgentMemory),
		events:          make([]WorkbenchEvent, 0),
		snapshots:       make([]SessionSnapshot, 0),
		projector:       NewStateProjector(session.MissionID, session.CurrentObjective, 5),
	}
}

// GetProjector returns the StateProjector for SSE streaming.
func (o *Orchestrator) GetProjector() *StateProjector {
	return o.projector
}

// HandleCommand processes a user command and orchestrates the response.
// This is the ONLY entry point for all Workbench activity.
func (o *Orchestrator) HandleCommand(ctx context.Context, cmd Command) error {
	switch cmd.Type {
	case CmdRunCode:
		return o.handleRunCode(ctx, cmd)
	case CmdAskMentor:
		return o.handleAskMentor(ctx, cmd)
	case CmdSubmit:
		return o.handleSubmit(ctx, cmd)
	case CmdAbandon:
		return o.handleAbandon(ctx, cmd)
	case CmdSaveFile:
		return o.handleSaveFile(ctx, cmd)
	case CmdCreateArtifact:
		return o.handleCreateArtifact(ctx, cmd)
	default:
		return o.handleGenericCommand(ctx, cmd)
	}
}

func (o *Orchestrator) handleRunCode(ctx context.Context, cmd Command) error {
	// 1. Parse payload
	var payload struct {
		SourceCode string `json:"source_code"`
		Language   string `json:"language"`
	}
	if err := json.Unmarshal(cmd.Payload, &payload); err != nil {
		return err
	}

	// 2. Policy selects the runtime
	rule, err := o.policy.Evaluate(ctx, runtime.ContextEducation, payload.Language)
	if err != nil {
		return err
	}
	rt, err := o.policy.SelectRuntime(ctx, rule, o.runtimeRegistry)
	if err != nil {
		return err
	}

	// 3. Build execution request
	req := runtime.ExecutionRequest{
		SessionID:      o.session.ID,
		MissionID:      o.session.MissionID,
		RequestID:      ulid.Make().String(),
		Language:       payload.Language,
		SourceCode:     payload.SourceCode,
		TimeoutSeconds: rule.MaxTimeoutSec,
		MemoryLimitMB:  rule.MaxMemoryMB,
		NetworkEnabled: rule.NetworkAllowed,
	}

	// 4. Prepare → Execute (Runtime only returns facts)
	if err := rt.Prepare(ctx, req); err != nil {
		return err
	}
	result, err := rt.Execute(ctx, req)
	if err != nil {
		return err
	}

	// 5. Evaluator produces assessment (interpretation)
	assessment, err := o.evaluator.Assess(ctx, result)
	if err != nil {
		return err
	}

	// 6. Objective Engine checks if objective is met
	objStatus := o.objectiveEngine.Check(ctx, assessment, o.session.CurrentObjective)

	// 7. Update live Mission Summary Projection
	o.session.RunCount++
	o.session.CompileCount++

	// 8. Update Cognitive State FSM
	newState := o.cognitiveFSM.Transition(ctx, o.session.CurrentCognitiveState, string(domain.WBEventToolExecuted))
	if newState != nil {
		o.session.CurrentCognitiveState = *newState
	}

	// 9. Emit ToolExecuted event (ONLY from Session)
	resultJSON, _ := json.Marshal(result)
	o.emitEvent(domain.WBEventToolExecuted, "RUNTIME", rt.Info().Name, resultJSON)

	// 10. If objective completed, emit that too
	if objStatus.Completed {
		statusJSON, _ := json.Marshal(objStatus)
		o.emitEvent(domain.WBEventObjectiveCompleted, "SYSTEM", "objective_engine", statusJSON)
	}

	// 11. Capture session snapshot
	o.captureSnapshot()

	// 12. Cleanup
	_ = rt.Cleanup(ctx, o.session.ID)

	return nil
}

func (o *Orchestrator) handleAskMentor(ctx context.Context, cmd Command) error {
	return o.handleAgentRequest(ctx, cmd, "python_mentor")
}

func (o *Orchestrator) handleAskQA(ctx context.Context, cmd Command) error {
	return o.handleAgentRequest(ctx, cmd, "python_qa")
}

func (o *Orchestrator) handleAgentRequest(ctx context.Context, cmd Command, roleID string) error {
	// 1. Update live counters
	o.session.AICallCount++
	o.session.HintCount++

	// 2. Emit AgentRequested event
	o.emitEvent(domain.WBEventAgentRequested, "USER", o.session.UserID, cmd.Payload)

	// 3. Update Cognitive State FSM
	newState := o.cognitiveFSM.Transition(ctx, o.session.CurrentCognitiveState, string(domain.WBEventAgentRequested))
	if newState != nil {
		o.session.CurrentCognitiveState = *newState
	}

	// 4. Get or create the Agent for this role
	ag, err := o.getOrCreateAgent(ctx, roleID)
	if err != nil {
		return err
	}

	// 5. Full Agent cognitive loop: Observe → Think → Respond → Act → Reflect
	obs := agent.Observation{
		SessionID:    o.session.ID,
		EventType:    string(cmd.Type),
		ActorTrigger: o.session.UserID,
		Payload:      payloadToMap(cmd.Payload),
		Context:      payloadToStringMap(cmd.Payload),
	}
	if err := ag.Observe(ctx, obs); err != nil {
		return err
	}

	thought, err := ag.Think(ctx)
	if err != nil {
		return err
	}

	response, err := ag.Respond(ctx, thought)
	if err != nil {
		return err
	}

	action, _ := ag.Act(ctx, response)
	_, _ = ag.Reflect(ctx, action)

	// 6. Emit AgentResponded event with the LLM response
	responseJSON, _ := json.Marshal(response)
	o.emitEvent(domain.WBEventAgentResponded, response.AgentRole, response.AgentID, responseJSON)

	// 7. Capture snapshot
	o.captureSnapshot()

	return nil
}

// getOrCreateAgent lazily creates an agent for a given role, with ephemeral memory.
func (o *Orchestrator) getOrCreateAgent(ctx context.Context, roleID string) (agent.Agent, error) {
	if ag, ok := o.agents[roleID]; ok {
		return ag, nil
	}

	role, ok := o.roleRegistry.Get(roleID)
	if !ok {
		return nil, fmt.Errorf("unknown agent role: %s", roleID)
	}

	memory := agent.NewInMemoryAgentMemory()
	o.agentMemories[roleID] = memory

	ag, err := o.agentFactory.Create(ctx, *role, memory)
	if err != nil {
		return nil, err
	}
	o.agents[roleID] = ag
	return ag, nil
}

func payloadToMap(raw json.RawMessage) map[string]any {
	var m map[string]any
	_ = json.Unmarshal(raw, &m)
	if m == nil {
		m = make(map[string]any)
	}
	return m
}

func payloadToStringMap(raw json.RawMessage) map[string]string {
	var m map[string]any
	_ = json.Unmarshal(raw, &m)
	result := make(map[string]string)
	for k, v := range m {
		result[k] = fmt.Sprintf("%v", v)
	}
	return result
}

func (o *Orchestrator) handleSubmit(ctx context.Context, cmd Command) error {
	now := time.Now()
	o.session.Status = SessionStatusCompleted
	o.session.CompletedAt = &now

	// Emit MissionCompleted
	summaryJSON, _ := json.Marshal(o.session)
	o.emitEvent(domain.WBEventMissionCompleted, "SYSTEM", "session_orchestrator", summaryJSON)

	// Update Cognitive State to COMPLETED
	o.session.CurrentCognitiveState = domain.CognitiveStateCompleted

	// Final snapshot
	o.captureSnapshot()

	return nil
}

func (o *Orchestrator) handleAbandon(ctx context.Context, cmd Command) error {
	now := time.Now()
	o.session.Status = SessionStatusAbandoned
	o.session.CompletedAt = &now
	o.emitEvent(domain.WBEventMissionCompleted, "SYSTEM", "session_orchestrator", cmd.Payload)
	o.captureSnapshot()
	return nil
}

func (o *Orchestrator) handleSaveFile(ctx context.Context, cmd Command) error {
	o.emitEvent(domain.WBEventEnvironmentChanged, "USER", o.session.UserID, cmd.Payload)
	newState := o.cognitiveFSM.Transition(ctx, o.session.CurrentCognitiveState, string(domain.WBEventEnvironmentChanged))
	if newState != nil {
		o.session.CurrentCognitiveState = *newState
	}
	return nil
}

func (o *Orchestrator) handleCreateArtifact(ctx context.Context, cmd Command) error {
	o.session.ArtifactCount++
	o.emitEvent(domain.WBEventArtifactCreated, "USER", o.session.UserID, cmd.Payload)
	return nil
}

func (o *Orchestrator) handleGenericCommand(ctx context.Context, cmd Command) error {
	o.emitEvent(domain.WBEventToolRequested, "USER", o.session.UserID, cmd.Payload)
	return nil
}

// emitEvent creates a WorkbenchEvent. ONLY the Orchestrator calls this.
func (o *Orchestrator) emitEvent(eventType domain.WorkbenchEventType, actorType, actorID string, payload json.RawMessage) {
	now := time.Now()
	evt := WorkbenchEvent{
		ID:                    ulid.Make().String(),
		SessionID:             o.session.ID,
		Type:                  eventType,
		ActorType:             actorType,
		ActorID:               actorID,
		Payload:               payload,
		CognitiveStateAtEvent: o.session.CurrentCognitiveState,
		RelativeMs:            now.Sub(o.session.StartedAt).Milliseconds(),
		OccurredAt:            now,
	}
	o.events = append(o.events, evt)
}

// captureSnapshot takes a checkpoint of the current session state.
func (o *Orchestrator) captureSnapshot() {
	snap := SessionSnapshot{
		ID:                    ulid.Make().String(),
		SessionID:             o.session.ID,
		CurrentObjective:      o.session.CurrentObjective,
		CurrentCognitiveState: o.session.CurrentCognitiveState,
		CompileCount:          o.session.CompileCount,
		RunCount:              o.session.RunCount,
		AICallCount:           o.session.AICallCount,
		CapturedAt:            time.Now(),
	}
	o.snapshots = append(o.snapshots, snap)
}

// GetSession returns the current session state.
func (o *Orchestrator) GetSession() *MissionSession { return o.session }

// DrainEvents returns all emitted events and clears the buffer.
func (o *Orchestrator) DrainEvents() []WorkbenchEvent {
	evts := o.events
	o.events = make([]WorkbenchEvent, 0)
	return evts
}

// DrainSnapshots returns all captured snapshots and clears the buffer.
func (o *Orchestrator) DrainSnapshots() []SessionSnapshot {
	snaps := o.snapshots
	o.snapshots = make([]SessionSnapshot, 0)
	return snaps
}
