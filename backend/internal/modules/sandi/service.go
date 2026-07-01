package sandi

import (
	"crypto/sha256"
	"fmt"

	"github.com/redis/go-redis/v9"

	"github.com/khasyaraka/backend/internal/xp"
)

type Service struct {
	repo *Repository
	rdb  *redis.Client
}

func NewService(repo *Repository, rdb *redis.Client) *Service {
	return &Service{repo: repo, rdb: rdb}
}

func (s *Service) GetTypes() ([]SandiType, error) {
	return s.repo.GetTypes()
}

func (s *Service) GetTypeDetail(id int64) (*SandiType, []SandiQuestion, error) {
	st, err := s.repo.GetTypeByID(id)
	if err != nil {
		return nil, nil, err
	}
	if st == nil {
		return nil, nil, fmt.Errorf("sandi type not found")
	}

	questions, err := s.repo.GetQuestionsBySandiID(id)
	if err != nil {
		return nil, nil, err
	}

	for i := range questions {
		questions[i].CorrectAnswer = ""
	}

	return st, questions, nil
}

func (s *Service) SolveQuestion(userID int64, questionID int64, answer string) (bool, int, error) {
	q, err := s.repo.GetQuestionByID(questionID)
	if err != nil {
		return false, 0, err
	}
	if q == nil {
		return false, 0, fmt.Errorf("question not found")
	}

	if answer != q.CorrectAnswer {
		return false, 0, nil
	}

	if err := s.repo.UpdateUserXP(userID, q.XpReward); err != nil {
		return false, 0, err
	}

	if err := xp.SyncToRedis(s.repo.db, s.rdb, userID); err != nil {
		return false, 0, err
	}

	return true, q.XpReward, nil
}

func (s *Service) Encrypt(userID int64, req CryptoRequest) (*CryptoResponse, error) {
	st, err := s.repo.GetTypeByID(req.SandiID)
	if err != nil || st == nil {
		return nil, fmt.Errorf("sandi type not found")
	}

	cipher, ok := GetCipher(st.Codename)
	if !ok {
		return nil, fmt.Errorf("unsupported sandi type: %s", st.Codename)
	}

	result, err := cipher.Encrypt(req.Text, req.Key)
	if err != nil {
		return nil, fmt.Errorf("encryption failed: %w", err)
	}

	inputHash := fmt.Sprintf("%x", sha256.Sum256([]byte(req.Text)))
	if err := s.repo.LogEncryption(userID, req.SandiID, inputHash, "encrypt"); err != nil {
		return nil, err
	}

	resp := &CryptoResponse{
		Result:       result,
		Method:       fmt.Sprintf("%s (encrypt)", cipher.Name()),
		TypeName:     st.Name,
		Codename:     st.Codename,
		InputLength:  len(req.Text),
		OutputLength: len(result),
	}
	if req.Key != "" {
		resp.KeyUsed = req.Key
	}
	return resp, nil
}

func (s *Service) Decrypt(userID int64, req CryptoRequest) (*CryptoResponse, error) {
	st, err := s.repo.GetTypeByID(req.SandiID)
	if err != nil || st == nil {
		return nil, fmt.Errorf("sandi type not found")
	}

	cipher, ok := GetCipher(st.Codename)
	if !ok {
		return nil, fmt.Errorf("unsupported sandi type: %s", st.Codename)
	}

	result, err := cipher.Decrypt(req.Text, req.Key)
	if err != nil {
		return nil, fmt.Errorf("decryption failed: %w", err)
	}

	inputHash := fmt.Sprintf("%x", sha256.Sum256([]byte(req.Text)))
	if err := s.repo.LogEncryption(userID, req.SandiID, inputHash, "decrypt"); err != nil {
		return nil, err
	}

	resp := &CryptoResponse{
		Result:       result,
		Method:       fmt.Sprintf("%s (decrypt)", cipher.Name()),
		TypeName:     st.Name,
		Codename:     st.Codename,
		InputLength:  len(req.Text),
		OutputLength: len(result),
	}
	if req.Key != "" {
		resp.KeyUsed = req.Key
	}
	return resp, nil
}
