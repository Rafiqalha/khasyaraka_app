package services

import (
	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

type KnowledgeService struct{}

func NewKnowledgeService() *KnowledgeService {
	return &KnowledgeService{}
}

func (s *KnowledgeService) ID() string {
	return "knowledge_service"
}

func (s *KnowledgeService) Initialize(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("KnowledgeService initialized")
	return nil
}

func (s *KnowledgeService) Execute(ctx kernel.RuntimeContext) error {
	return nil
}

func (s *KnowledgeService) Shutdown(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("KnowledgeService shutdown")
	return nil
}

type FileService struct{}

func NewFileService() *FileService {
	return &FileService{}
}

func (s *FileService) ID() string {
	return "file_service"
}

func (s *FileService) Initialize(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("FileService initialized")
	return nil
}

func (s *FileService) Execute(ctx kernel.RuntimeContext) error {
	return nil
}

func (s *FileService) Shutdown(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("FileService shutdown")
	return nil
}

type NotebookService struct{}

func NewNotebookService() *NotebookService {
	return &NotebookService{}
}

func (s *NotebookService) ID() string {
	return "notebook_service"
}

func (s *NotebookService) Initialize(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("NotebookService initialized")
	return nil
}

func (s *NotebookService) Execute(ctx kernel.RuntimeContext) error {
	return nil
}

func (s *NotebookService) Shutdown(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("NotebookService shutdown")
	return nil
}
