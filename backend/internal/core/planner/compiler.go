package planner

import (
	"context"
	"fmt"
	"time"

	"github.com/pradigi/backend/internal/core/pack"
)

// ExecutionPlan is the strategic plan produced by the Planner before compilation.
type ExecutionPlan struct {
	PackID           string                  `json:"pack_id"`
	PackVersion      string                  `json:"pack_version"`
	PackChecksum     string                  `json:"pack_checksum"`
	MissionQueue     []pack.MissionBlueprint `json:"mission_queue"`
	CapabilityTarget []string                `json:"capability_target"`
	DifficultyLevel  string                  `json:"difficulty_level"`
	EstimatedTimeSec int                     `json:"estimated_time_sec"`
	PedagogyStrategy string                  `json:"pedagogy_strategy"`
}

// CompiledRuntime represents the compiled runtime session ready for execution by the Runtime Kernel.
type CompiledRuntime struct {
	ID                 string                  `json:"id"`
	UserID             string                  `json:"user_id"`
	PackID             string                  `json:"pack_id"`
	PackVersion        string                  `json:"pack_version"`
	PackChecksum       string                  `json:"pack_checksum"`
	Status             string                  `json:"status"` // CREATED -> PROVISIONING -> RUNNING -> COMPLETED
	CurrentMissionIndex int                    `json:"current_mission_index"`
	Missions           []pack.MissionBlueprint `json:"missions"`
	CompiledAt         time.Time               `json:"compiled_at"`
}

// BlueprintCompiler compiles an ExecutionPlan into a CompiledRuntime.
type BlueprintCompiler struct{}

func NewBlueprintCompiler() *BlueprintCompiler {
	return &BlueprintCompiler{}
}

func (c *BlueprintCompiler) Compile(ctx context.Context, userID string, plan *ExecutionPlan, p *pack.Pack) (*CompiledRuntime, error) {
	if p == nil {
		return nil, fmt.Errorf("blueprint compiler: pack cannot be nil")
	}
	if len(plan.MissionQueue) == 0 {
		return nil, fmt.Errorf("blueprint compiler: execution plan mission queue cannot be empty")
	}

	runtimeID := fmt.Sprintf("rt_%s_%d", p.Descriptor.ID, time.Now().UnixNano())

	return &CompiledRuntime{
		ID:                  runtimeID,
		UserID:              userID,
		PackID:              p.Descriptor.ID,
		PackVersion:         p.Descriptor.Version,
		PackChecksum:        p.Checksum,
		Status:              "CREATED",
		CurrentMissionIndex: 0,
		Missions:            plan.MissionQueue,
		CompiledAt:          time.Now(),
	}, nil
}
