package portfolio

import (
	"context"
)

type CuratedAsset struct {
	AssetID     string   `json:"asset_id"`
	Title       string   `json:"title"`
	Description string   `json:"description"`
	Tags        []string `json:"tags"`
	Weight      float64  `json:"weight"`
}

type AutoCurator interface {
	CurateEvidence(ctx context.Context, evidencePayload []byte) (*CuratedAsset, error)
}

type curator struct {}

func NewAutoCurator() AutoCurator {
	return &curator{}
}

func (c *curator) CurateEvidence(ctx context.Context, evidencePayload []byte) (*CuratedAsset, error) {
	// For MVP, simulate AI curation of evidence into a portfolio asset.
	// In reality: Ask AI to generate a polished title/description from the raw Evidence.
	
	asset := &CuratedAsset{
		AssetID:     "asset_123",
		Title:       "Built an API using Golang",
		Description: "Implemented a REST API utilizing Gin and SQLx, following clean architecture.",
		Tags:        []string{"golang", "api", "architecture"},
		Weight:      10.5,
	}
	return asset, nil
}
