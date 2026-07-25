package resolver

import (
	"context"

	"github.com/pradigi/backend/internal/core/catalog"
)

type IntentRequest struct {
	Version         int
	Academy         string
	Specialization  string
	Mission         string
	Experience      string
	ExecutionIntent string
}

type Resolution struct {
	GoalID           string
	PathID           string
	InitialPackID    string
	TrajectoryID     string
	RuntimeProfileID string
}

type Resolver interface {
	Resolve(ctx context.Context, intent IntentRequest) (*Resolution, error)
	ResolveExperience(ctx context.Context, intent IntentRequest) (*catalog.ExperienceBlueprint, *catalog.PackBlueprint, error)
	Validate() error
	Recommend() error
	Preview() error
}

type osResolver struct {
	catalog   catalog.Repository
	registry *catalog.BlueprintRegistry
}

func NewResolver(cat catalog.Repository, registry ...*catalog.BlueprintRegistry) Resolver {
	var reg *catalog.BlueprintRegistry
	if len(registry) > 0 {
		reg = registry[0]
	}
	return &osResolver{catalog: cat, registry: reg}
}

func (r *osResolver) ResolveExperience(ctx context.Context, intent IntentRequest) (*catalog.ExperienceBlueprint, *catalog.PackBlueprint, error) {
	if r.registry == nil {
		return nil, nil, nil
	}
	if intent.Experience != "" {
		if exp, ok := r.registry.GetExperience(intent.Experience); ok {
			var pack *catalog.PackBlueprint
			if len(exp.Packs) > 0 {
				pack, _ = r.registry.GetPack(exp.Packs[0])
			}
			return exp, pack, nil
		}
	}
	if intent.Specialization != "" {
		if pack, ok := r.registry.GetPack(intent.Specialization); ok {
			return nil, pack, nil
		}
	}
	return nil, nil, nil
}

func (r *osResolver) Resolve(ctx context.Context, intent IntentRequest) (*Resolution, error) {
	// For MVP, map Specialization (which acts as the destination in Phase A) directly to Goal Slug
	// since Specializations like "soc_analyst" correspond to the primary goal "soc-analyst"
	goalSlug := intent.Specialization

	goal, err := r.catalog.FindGoalBySlug(ctx, goalSlug)
	if err != nil {
		return nil, err
	}
	if goal == nil {
		// Goal not found
		return nil, nil // Should return custom error later
	}

	res := &Resolution{
		GoalID: goal.ID,
		// Mock Path and Pack IDs for MVP until they are properly implemented in catalog
		PathID:        "path_mock",
		InitialPackID: "pack_mock",
	}

	return res, nil
}

func (r *osResolver) Validate() error {
	return nil
}

func (r *osResolver) Recommend() error {
	return nil
}

func (r *osResolver) Preview() error {
	return nil
}
