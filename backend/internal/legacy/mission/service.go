package mission

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/redis/go-redis/v9"
)

type Service struct {
	repo   *Repository
	rdb    *redis.Client
	hub    *MissionHub
	ai     *MissionAI
	mu     sync.Mutex
	states map[string]*MissionState
}

func NewService(repo *Repository, rdb *redis.Client, ai *MissionAI) *Service {
	s := &Service{
		repo:   repo,
		rdb:    rdb,
		hub:    NewMissionHub(rdb),
		ai:     ai,
		states: make(map[string]*MissionState),
	}
	go s.hub.Run()
	return s
}

func (s *Service) GenerateMission(userID int64, persona string) (*MissionState, error) {
	state, err := GenerateMission(persona)
	if err != nil {
		return nil, err
	}

	s.mu.Lock()
	s.states[state.MissionID] = state
	s.mu.Unlock()

	saveStateToRedis(s.rdb, state.MissionID, state)

	go s.runStateMachine(state.MissionID)

	return state, nil
}

func (s *Service) ProcessAction(missionID string, action MissionAction) (*ActionResult, error) {
	s.mu.Lock()
	state, exists := s.states[missionID]
	s.mu.Unlock()

	if !exists {
		return nil, fmt.Errorf("mission %s not active", missionID)
	}

	result := state.ProcessAction(action)
	s.mu.Lock()
	s.states[missionID] = state
	s.mu.Unlock()

	saveStateToRedis(s.rdb, missionID, state)

	for _, evt := range result.Events {
		s.hub.Broadcast(missionID, evt)
	}

	if result.MissionStatus == "completed" || state.ServerHealth <= 0 || state.TimeRemaining <= 0 {
		result.NewState = state
		result.MissionStatus = "completed"
	}

	return &result, nil
}

func (s *Service) GetState(missionID string) (*MissionState, error) {
	s.mu.Lock()
	state, exists := s.states[missionID]
	s.mu.Unlock()

	if exists {
		return state, nil
	}

	state, err := loadStateFromRedis(s.rdb, missionID)
	if err != nil {
		return nil, err
	}

	s.mu.Lock()
	s.states[missionID] = state
	s.mu.Unlock()

	return state, nil
}

func (s *Service) Subscribe(missionID string, ch chan EnvironmentEvent) {
	s.hub.Subscribe(missionID, ch)
}

func (s *Service) Unsubscribe(missionID string, ch chan EnvironmentEvent) {
	s.hub.Unsubscribe(missionID, ch)
}

func (s *Service) runStateMachine(missionID string) {
	ticker := time.NewTicker(3 * time.Second)
	defer ticker.Stop()

	timer := time.NewTicker(1 * time.Second)
	defer timer.Stop()

	for {
		select {
		case <-ticker.C:
			s.mu.Lock()
			state, exists := s.states[missionID]
			s.mu.Unlock()

			if !exists || state.ServerHealth <= 0 || state.TimeRemaining <= 0 {
				return
			}

			if s.ai != nil {
				decision, err := s.ai.DecideNextMove(context.Background(), state)
				if err == nil && decision != nil {
					decision.applyToMission(state)
					evt := EnvironmentEvent{
						Type: decision.Action, Severity: decision.Severity,
						Message: decision.Message, ServerID: decision.TargetServerID,
						SourceIP: "192.168.1.105",
					}
					s.hub.Broadcast(missionID, evt)
				}
			} else {
				events := state.EvaluateTransitions(state.AttackerPersona)
				for _, evt := range events {
					s.hub.Broadcast(missionID, evt)
				}
			}

			s.mu.Lock()
			s.states[missionID] = state
			s.mu.Unlock()

			saveStateToRedis(s.rdb, missionID, state)

		case <-timer.C:
			s.mu.Lock()
			state, exists := s.states[missionID]
			s.mu.Unlock()

			if !exists {
				return
			}

			state.TimeRemaining--
			s.mu.Lock()
			s.states[missionID] = state
			s.mu.Unlock()

			saveStateToRedis(s.rdb, missionID, state)

			if state.TimeRemaining <= 0 {
				s.hub.Broadcast(missionID, EnvironmentEvent{
					Type: "mission_timeout", Severity: "critical",
					Message: "⏰ MISSION TIME EXPIRED",
				})
				return
			}
		}
	}
}

func saveStateToRedis(rdb *redis.Client, missionID string, state *MissionState) {
	ctx := context.Background()
	data, _ := json.Marshal(state)
	rdb.Set(ctx, fmt.Sprintf("mission:%s", missionID), string(data), 10*time.Minute)
}

func loadStateFromRedis(rdb *redis.Client, missionID string) (*MissionState, error) {
	ctx := context.Background()
	data, err := rdb.Get(ctx, fmt.Sprintf("mission:%s", missionID)).Result()
	if err != nil {
		return nil, fmt.Errorf("mission %s not found", missionID)
	}
	var state MissionState
	if err := json.Unmarshal([]byte(data), &state); err != nil {
		return nil, err
	}
	return &state, nil
}
