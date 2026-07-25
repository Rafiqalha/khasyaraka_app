package academy

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

// GetAllAcademies returns all academies without nested relations.
func (r *Repository) GetAllAcademies(ctx context.Context) ([]Academy, error) {
	var academies []Academy
	query := `SELECT * FROM academies ORDER BY created_at ASC`
	if err := r.db.SelectContext(ctx, &academies, query); err != nil {
		return nil, err
	}
	return academies, nil
}

// GetAcademyTree returns an academy along with its domains, specializations, and journeys.
func (r *Repository) GetAcademyTree(ctx context.Context, academyID string) (*AcademyTree, error) {
	var academy Academy
	queryAcademy := `SELECT * FROM academies WHERE id = $1`
	if err := r.db.GetContext(ctx, &academy, queryAcademy, academyID); err != nil {
		return nil, err
	}

	var domains []Domain
	queryDomains := `SELECT * FROM domains WHERE academy_id = $1 ORDER BY created_at ASC`
	if err := r.db.SelectContext(ctx, &domains, queryDomains, academyID); err != nil {
		return nil, err
	}

	var specializations []Specialization
	querySpecs := `SELECT s.* FROM specializations s 
	               JOIN domains d ON s.domain_id = d.id 
	               WHERE d.academy_id = $1 ORDER BY s.created_at ASC`
	if err := r.db.SelectContext(ctx, &specializations, querySpecs, academyID); err != nil {
		return nil, err
	}

	var learningGoals []LearningGoal
	queryGoals := `SELECT g.* FROM learning_goals g 
	                  JOIN specializations s ON g.specialization_id = s.id 
	                  JOIN domains d ON s.domain_id = d.id 
	                  WHERE d.academy_id = $1 ORDER BY g.created_at ASC`
	if err := r.db.SelectContext(ctx, &learningGoals, queryGoals, academyID); err != nil {
		return nil, err
	}

	// Reconstruct the tree
	specMap := make(map[string][]LearningGoalTree)
	for _, g := range learningGoals {
		specMap[g.SpecializationID] = append(specMap[g.SpecializationID], LearningGoalTree{LearningGoal: g})
	}

	domainMap := make(map[string][]SpecializationTree)
	for _, s := range specializations {
		st := SpecializationTree{
			Specialization: s,
			LearningGoals:  specMap[s.ID],
		}
		if st.LearningGoals == nil {
			st.LearningGoals = []LearningGoalTree{} // Ensure it's not null in JSON
		}
		domainMap[s.DomainID] = append(domainMap[s.DomainID], st)
	}

	var domainTrees []DomainTree
	for _, d := range domains {
		dt := DomainTree{
			Domain:          d,
			Specializations: domainMap[d.ID],
		}
		if dt.Specializations == nil {
			dt.Specializations = []SpecializationTree{} // Ensure it's not null in JSON
		}
		domainTrees = append(domainTrees, dt)
	}

	return &AcademyTree{
		Academy: academy,
		Domains: domainTrees,
	}, nil
}

// GetAcademySpecializations returns just the specializations with their learning goals for an academy
func (r *Repository) GetAcademySpecializations(ctx context.Context, academyID string) ([]SpecializationTree, error) {
	var specializations []Specialization
	querySpecs := `SELECT s.* FROM specializations s 
	               JOIN domains d ON s.domain_id = d.id 
	               WHERE d.academy_id = $1 ORDER BY s.created_at ASC`
	if err := r.db.SelectContext(ctx, &specializations, querySpecs, academyID); err != nil {
		return nil, err
	}

	var learningGoals []LearningGoal
	queryGoals := `SELECT g.* FROM learning_goals g 
	                  JOIN specializations s ON g.specialization_id = s.id 
	                  JOIN domains d ON s.domain_id = d.id 
	                  WHERE d.academy_id = $1 ORDER BY g.created_at ASC`
	if err := r.db.SelectContext(ctx, &learningGoals, queryGoals, academyID); err != nil {
		return nil, err
	}

	specMap := make(map[string][]LearningGoalTree)
	for _, g := range learningGoals {
		specMap[g.SpecializationID] = append(specMap[g.SpecializationID], LearningGoalTree{LearningGoal: g})
	}

	var result []SpecializationTree
	for _, s := range specializations {
		st := SpecializationTree{
			Specialization: s,
			LearningGoals:  specMap[s.ID],
		}
		if st.LearningGoals == nil {
			st.LearningGoals = []LearningGoalTree{}
		}
		result = append(result, st)
	}

	return result, nil
}

func (r *Repository) CreateProfile(ctx context.Context, profile *LearningProfile) error {
	query := `
		INSERT INTO learning_profiles (user_id, goal, experience, endgame, learning_goal_id)
		VALUES (:user_id, :goal, :experience, :endgame, :learning_goal_id)
		ON CONFLICT (user_id) DO UPDATE SET
			goal = EXCLUDED.goal,
			experience = EXCLUDED.experience,
			endgame = EXCLUDED.endgame,
			learning_goal_id = EXCLUDED.learning_goal_id,
			updated_at = NOW()
	`
	_, err := r.db.NamedExecContext(ctx, query, profile)
	return err
}

func (r *Repository) GetProfile(ctx context.Context, userID string) (*LearningProfile, error) {
	var profile LearningProfile
	query := `SELECT * FROM learning_profiles WHERE user_id = $1 LIMIT 1`
	err := r.db.GetContext(ctx, &profile, query, userID)
	if err != nil {
		return nil, err
	}
	return &profile, nil
}

type ActiveJourneyData struct {
	EnrollmentID      string  `db:"enrollment_id"`
	BlueprintVersion  string  `db:"blueprint_version"`
	Specialization    string  `db:"specialization"`
	CapabilityScore   float64 `db:"capability_score"` // Example placeholder
	RuntimeSessionID  *string `db:"runtime_session_id"`
	CurrentMission    *string `db:"current_mission"` // Example placeholder
}

func (r *Repository) GetActiveJourney(ctx context.Context, userID string) (*ActiveJourneyData, error) {
	var journey ActiveJourneyData
	query := `
		SELECT 
			e.id as enrollment_id,
			e.blueprint_version,
			s.title as specialization,
			0.0 as capability_score, -- Stub for derived capability
			rs.id as runtime_session_id,
			'Start Your Mission' as current_mission -- Stub for derived daily mission
		FROM learning_enrollments e
		JOIN specializations s ON e.specialization_id = s.id
		LEFT JOIN runtime_sessions rs ON rs.enrollment_id = e.id
		WHERE e.user_id = $1 AND e.status = 'ACTIVE'
		ORDER BY e.updated_at DESC
		LIMIT 1
	`
	err := r.db.GetContext(ctx, &journey, query, userID)
	if err != nil {
		return nil, err
	}
	return &journey, nil
}
