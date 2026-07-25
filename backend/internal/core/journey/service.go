package journey

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/pradigi/backend/internal/core/catalog"
	"github.com/pradigi/backend/internal/core/mission_engine"
	"github.com/pradigi/backend/internal/core/pack"
	"github.com/pradigi/backend/internal/core/planner"
)

type Service interface {
	InitializeJourney(ctx context.Context, userID, academyID, specializationID string) (map[string]string, error)
}

type journeyService struct {
	catalogRepo    catalog.Repository
	packRegistry   pack.Registry
	packLoader     pack.Loader
	planner        planner.Planner
	contextBuilder mission_engine.ContextBuilder
	missionEngine  *mission_engine.Engine
	// compiler *mission_compiler.Compiler // We'll add this when needed
}

func NewService(
	catalogRepo catalog.Repository,
	packRegistry pack.Registry,
	packLoader pack.Loader,
	planr planner.Planner,
	ctxBuilder mission_engine.ContextBuilder,
	engine *mission_engine.Engine,
) Service {
	return &journeyService{
		catalogRepo:    catalogRepo,
		packRegistry:   packRegistry,
		packLoader:     packLoader,
		planner:        planr,
		contextBuilder: ctxBuilder,
		missionEngine:  engine,
	}
}

func (s *journeyService) InitializeJourney(ctx context.Context, userID, academyID, specializationID string) (map[string]string, error) {
	// Step 1: Pack Registry (Find Pack Blueprint)
	// For now, we assume specializationID maps directly to a pack ID (or we can lookup the pack ID).
	// Let's hardcode a fallback if not found, since registry might not have it yet.
	packID := specializationID
	desc, err := s.packRegistry.Get(packID)
	if err != nil {
		// Fallback for Phase E validation
		packID = "backend_engineering"
		desc, err = s.packRegistry.Get(packID)
		if err != nil {
			return nil, err
		}
	}

	// Step 2: Blueprint Loader
	pkg, err := s.packLoader.Load(ctx, desc)
	if err != nil {
		return nil, err
	}

	// Step 3: Enrollment (Commit to DB immediately to get an EnrollmentID)
	enrollmentID := "enr_" + time.Now().Format("20060102150405")
	runtimeID := uuid.New().String()
	snapshotID := "snp_" + time.Now().Format("20060102150405")

	err = s.catalogRepo.InitializeJourneyTransaction(ctx, userID, enrollmentID, runtimeID, snapshotID, academyID, specializationID)
	if err != nil {
		return nil, err
	}

	// Step 4: Knowledge Snapshot (Fetch user's current mastery state)
	// Mocking this for now as per pipeline
	capabilitySnapshot := planner.CapabilitySnapshot{}

	// Step 5: Planner (Create Strategy Snapshot based on Blueprint + Knowledge)
	plan, err := s.planner.Plan(ctx, runtimeID, pkg, capabilitySnapshot)
	if err != nil {
		// In a real system, we might mark the enrollment as FAILED or retry.
		return nil, err
	}

	// Step 6: Mission Engine (Context Builder & Generation)
	mctx, err := s.contextBuilder.BuildContext(ctx, plan, pkg.ReferencesPath)
	if err != nil {
		return nil, err
	}

	_, err = s.missionEngine.Generate(ctx, mctx)
	if err != nil {
		return nil, err
	}

	// Step 7: Compiler (Build Runtime Config) - Omitted for brevity in this slice
	// Step 8: Runtime (Initialize Session UUID) - Already generated runtimeID and persisted in Step 3!

	return map[string]string{
		"enrollment_id":      enrollmentID,
		"runtime_session_id": runtimeID,
	}, nil
}
