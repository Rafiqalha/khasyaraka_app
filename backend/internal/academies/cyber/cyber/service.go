// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package cyber

import (
	"fmt"

	"github.com/redis/go-redis/v9"

	"github.com/pradigi/backend/internal/xp"
)

type Service struct {
	repo *Repository
	rdb  *redis.Client
}

func NewService(repo *Repository, rdb *redis.Client) *Service {
	return &Service{repo: repo, rdb: rdb}
}

func (s *Service) GetModules(userID *int64) ([]ModuleBrief, error) {
	modules, err := s.repo.GetModulesWithCounts()
	if err != nil {
		return nil, err
	}

	if userID != nil {
		counts, err := s.repo.GetModuleSolvedCounts(*userID)
		if err != nil {
			return nil, err
		}
		for i := range modules {
			modules[i].Solved = counts[modules[i].ID]
		}
	}
	return modules, nil
}

func (s *Service) GetModuleDetail(id string, userID *int64) (*Module, error) {
	m, err := s.repo.GetModuleByID(id)
	if err != nil {
		return nil, err
	}
	if m == nil {
		return nil, fmt.Errorf("module not found")
	}

	challenges, err := s.repo.GetChallengesByModule(id)
	if err != nil {
		return nil, err
	}

	var solved map[string]bool
	if userID != nil {
		solved, err = s.repo.GetSolvedChallengeIDs(*userID)
		if err != nil {
			return nil, err
		}
	}

	for i := range challenges {
		challenges[i].IsSolved = solved[challenges[i].ID]
		challenges[i].DecryptedAnswer = ""
	}
	m.Challenges = challenges

	return m, nil
}

func (s *Service) GetChallenge(id string, userID int64) (*Challenge, error) {
	c, err := s.repo.GetChallengeByID(id)
	if err != nil {
		return nil, err
	}
	if c == nil {
		return nil, fmt.Errorf("challenge not found")
	}

	solved, err := s.repo.IsChallengeSolved(userID, id)
	if err != nil {
		return nil, err
	}
	c.IsSolved = solved
	c.DecryptedAnswer = ""

	return c, nil
}

func (s *Service) SolveChallenge(userID int64, challengeID string, answer string) (bool, int, error) {
	c, err := s.repo.GetChallengeByID(challengeID)
	if err != nil {
		return false, 0, err
	}
	if c == nil {
		return false, 0, fmt.Errorf("challenge not found")
	}

	solved, err := s.repo.IsChallengeSolved(userID, challengeID)
	if err != nil {
		return false, 0, err
	}
	if solved {
		return false, 0, fmt.Errorf("challenge already solved")
	}

	if answer != c.DecryptedAnswer {
		return false, 0, nil
	}

	if err := s.repo.MarkSolved(userID, challengeID); err != nil {
		return false, 0, err
	}

	if err := s.repo.UpsertLevelProgress(userID, c.ModuleID, c.Level, c.XpReward); err != nil {
		return false, 0, err
	}

	if err := s.repo.UpdateUserXP(userID, c.XpReward); err != nil {
		return false, 0, err
	}

	if err := xp.SyncToRedis(s.repo.db, s.rdb, userID); err != nil {
		return false, 0, err
	}

	return true, c.XpReward, nil
}
