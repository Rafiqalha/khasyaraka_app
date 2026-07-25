package catalog

import (
	"context"
)

type Service interface {
	GetAcademies(ctx context.Context) ([]Academy, error)
	GetSpecializations(ctx context.Context, academyID string) ([]Specialization, error)
	GetExperiences(ctx context.Context) ([]Experience, error)
	GetExecutionIntents(ctx context.Context) ([]ExecutionIntent, error)
}

type catalogService struct {
	repo       Repository
	loader     MetadataLoader
	catalogDir string
}

func NewService(repo Repository, loader MetadataLoader, catalogDir string) Service {
	return &catalogService{
		repo:       repo,
		loader:     loader,
		catalogDir: catalogDir,
	}
}

func (s *catalogService) GetAcademies(ctx context.Context) ([]Academy, error) {
	return s.repo.GetAllAcademies(ctx)
}

func (s *catalogService) GetSpecializations(ctx context.Context, academyID string) ([]Specialization, error) {
	return s.repo.GetSpecializationsByAcademyID(ctx, academyID)
}

func (s *catalogService) GetExperiences(ctx context.Context) ([]Experience, error) {
	return s.loader.LoadExperiences(s.catalogDir + "/experiences.yaml")
}

func (s *catalogService) GetExecutionIntents(ctx context.Context) ([]ExecutionIntent, error) {
	return s.loader.LoadExecutionIntents(s.catalogDir + "/intents.yaml")
}
