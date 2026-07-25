package portfolio

import (
	"context"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
)

type Evidence struct {
	ID          string    `json:"id" db:"id"`
	UserID      string    `json:"user_id" db:"user_id"`
	MissionID   string    `json:"mission_id" db:"mission_id"`
	Score       float64   `json:"score" db:"score"`
	EvidenceURL string    `json:"evidence_url" db:"evidence_url"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
}

type Artifact struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	FileType    string `json:"file_type"`
	URL         string `json:"url"`
}

type Certificate struct {
	ID         string    `json:"id"`
	UserID     string    `json:"user_id"`
	PackID     string    `json:"pack_id"`
	Title      string    `json:"title"`
	IssuedAt   time.Time `json:"issued_at"`
	VerifyCode string    `json:"verify_code"`
}

type ResumeItem struct {
	ID          string   `json:"id"`
	RoleTitle   string   `json:"role_title"`
	Highlights  []string `json:"highlights"`
	VerifiedCaps []string `json:"verified_caps"`
}

type PortfolioRecord struct {
	UserID       string        `json:"user_id"`
	Evidences    []Evidence    `json:"evidences"`
	Artifacts    []Artifact    `json:"artifacts"`
	Certificates []Certificate `json:"certificates"`
	ResumeItems  []ResumeItem  `json:"resume_items"`
}

type Generator struct {
	db *sqlx.DB
}

func NewGenerator(db *sqlx.DB) *Generator {
	return &Generator{db: db}
}

func (g *Generator) OnRuntimeCompleted(ctx context.Context, userID, packID, runtimeID string) (*PortfolioRecord, error) {
	verifyCode := fmt.Sprintf("CERT-%s-%d", packID, time.Now().Unix())
	
	cert := Certificate{
		ID:         fmt.Sprintf("cert_%d", time.Now().UnixNano()),
		UserID:     userID,
		PackID:     packID,
		Title:      fmt.Sprintf("Certified Specialist: %s", packID),
		IssuedAt:   time.Now(),
		VerifyCode: verifyCode,
	}

	record := &PortfolioRecord{
		UserID:       userID,
		Evidences:    []Evidence{},
		Artifacts:    []Artifact{},
		Certificates: []Certificate{cert},
		ResumeItems:  []ResumeItem{},
	}

	return record, nil
}
