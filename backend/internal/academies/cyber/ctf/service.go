// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package ctf

import (
	"context"
	"crypto/subtle"
	"errors"
	"time"

	"github.com/pradigi/backend/internal/legacy/ai"
	"github.com/pradigi/backend/internal/academies/cyber/arena"
	"github.com/pradigi/backend/internal/legacy/token"
)

type CTFService struct {
	repo         CTFRepository
	arenaRepo    *arena.Repository
	aiService    *ai.AIService
	tokenService *token.TokenService
}

func NewCTFService(repo CTFRepository, arenaRepo *arena.Repository, aiService *ai.AIService, tokenService *token.TokenService) *CTFService {
	return &CTFService{
		repo:         repo,
		arenaRepo:    arenaRepo,
		aiService:    aiService,
		tokenService: tokenService,
	}
}

func (s *CTFService) InitializeCTFRoom(ctx context.Context, roomID int64) (*CTFRoom, error) {
	// 1. Validate room exists (via arena repo, assuming it exists for now since this is isolated)
	// 2. Call repo.CreateCTFRoom()
	ctfRoom, err := s.repo.CreateCTFRoom(ctx, roomID, 180, 300)
	if err != nil {
		return nil, err
	}

	// 3. For each team in the room
	teams, err := s.arenaRepo.GetTeamsByRoomID(roomID)
	if err != nil {
		return nil, err
	}
	if len(teams) != 2 {
		return nil, errors.New("ctf mode requires exactly 2 teams")
	}

	for _, t := range teams {
		flag := GenerateFlag()
		img := GetRandomCulturalImage()
		err = s.repo.SaveDefense(ctx, ctfRoom.ID, t.ID, flag, img.URL, "", "")
		if err != nil {
			return nil, err
		}
	}

	return ctfRoom, nil
}

func (s *CTFService) StartDefensePhase(ctx context.Context, ctfRoomID int64) error {
	room, err := s.repo.GetCTFRoom(ctx, ctfRoomID)
	if err != nil {
		return err
	}
	if room == nil {
		return errors.New("ctf room not found")
	}
	if room.Phase != PhaseWaiting {
		return errors.New("can only start defense from waiting phase")
	}

	err = s.repo.UpdatePhase(ctx, ctfRoomID, PhaseDefense)
	if err != nil {
		return err
	}

	// Schedule auto-transition
	time.AfterFunc(time.Duration(room.DefenseDurationSec)*time.Second, func() {
		// Create new context for background job
		bgCtx := context.Background()
		_ = s.StartAttackPhase(bgCtx, ctfRoomID)
	})

	return nil
}

func (s *CTFService) SubmitDefense(ctx context.Context, ctfRoomID, teamID int64, req SubmitDefenseRequest) error {
	room, err := s.repo.GetCTFRoom(ctx, ctfRoomID)
	if err != nil {
		return err
	}
	if room.Phase != PhaseDefense {
		return errors.New("not in defense phase")
	}

	if req.CipherMethod != CipherCaesar && req.CipherMethod != CipherVigenere && req.CipherMethod != CipherMorse && req.CipherMethod != CipherKotak {
		return errors.New("invalid cipher method")
	}

	validImage := false
	var imgURL string
	for _, img := range CulturalImagePool {
		if img.ID == req.CulturalImageID {
			validImage = true
			imgURL = img.URL
			break
		}
	}
	if !validImage {
		return errors.New("invalid cultural image id")
	}

	team, err := s.repo.GetCTFTeam(ctx, ctfRoomID, teamID)
	if err != nil {
		return err
	}

	return s.repo.SaveDefense(ctx, ctfRoomID, teamID, team.Flag, imgURL, req.CipherMethod, req.CipherKey)
}

func (s *CTFService) StartAttackPhase(ctx context.Context, ctfRoomID int64) error {
	room, err := s.repo.GetCTFRoom(ctx, ctfRoomID)
	if err != nil {
		return err
	}
	if room.Phase != PhaseDefense && room.Phase != PhasePatching {
		// we can re-enter attack phase from patching
		return errors.New("cannot start attack phase now")
	}

	// Check if all teams have cipher method
	teams, err := s.repo.GetAllCTFTeams(ctx, ctfRoomID)
	if err != nil {
		return err
	}
	for _, t := range teams {
		if t.CipherMethod == "" {
			// Team didn't submit, auto assign
			_ = s.repo.SaveDefense(ctx, ctfRoomID, t.TeamID, t.Flag, t.DefenseImageURL, CipherCaesar, "3")
		}
	}

	err = s.repo.UpdatePhase(ctx, ctfRoomID, PhaseAttack)
	if err != nil {
		return err
	}

	// Schedule auto-finish if we are transitioning from Defense for the first time
	// (To be exact, we should track total attack time. Simplified for this requirement)
	if room.Phase == PhaseDefense {
		time.AfterFunc(time.Duration(room.AttackDurationSec)*time.Second, func() {
			bgCtx := context.Background()
			_, _ = s.FinishCTF(bgCtx, ctfRoomID)
		})
	}

	return nil
}

func (s *CTFService) AttackWithAI(ctx context.Context, ctfRoomID, teamID, userID int64, prompt string) (*ai.ChatResponse, error) {
	room, err := s.repo.GetCTFRoom(ctx, ctfRoomID)
	if err != nil {
		return nil, err
	}
	if room.Phase != PhaseAttack {
		return nil, errors.New("not in attack phase")
	}

	// Verify team hasn't found flag yet
	team, err := s.repo.GetCTFTeam(ctx, ctfRoomID, teamID)
	if err != nil {
		return nil, err
	}
	if team == nil {
		return nil, errors.New("team not found in CTF")
	}

	// We are attacking opponent. If we already found it, block.
	opponentID := s.getOpponentTeamID(ctx, ctfRoomID, teamID)
	opponentTeam, err := s.repo.GetCTFTeam(ctx, ctfRoomID, opponentID)
	if err != nil {
		return nil, err
	}
	if opponentTeam.FlagFound {
		return nil, errors.New("flag already found")
	}

	resp, err := s.aiService.ChatWithCustomPrompt(ctx, userID, CTF_ATTACK_SYSTEM_PROMPT, prompt)
	if err != nil {
		return nil, err
	}

	// Log attack
	log := &CTFAttackLog{
		CTFRoomID:       ctfRoomID,
		AttackingTeamID: teamID,
		UserID:          userID,
		Prompt:          prompt,
		AIResponse:      resp.Response,
		TokensUsed:      1,
	}
	_ = s.repo.SaveAttackLog(ctx, log)

	return resp, nil
}

func (s *CTFService) getOpponentTeamID(ctx context.Context, ctfRoomID, myTeamID int64) int64 {
	teams, _ := s.repo.GetAllCTFTeams(ctx, ctfRoomID)
	for _, t := range teams {
		if t.TeamID != myTeamID {
			return t.TeamID
		}
	}
	return 0
}

func (s *CTFService) SubmitFlag(ctx context.Context, ctfRoomID, attackingTeamID int64, submittedFlag string) (bool, error) {
	room, err := s.repo.GetCTFRoom(ctx, ctfRoomID)
	if err != nil {
		return false, err
	}
	if room.Phase != PhaseAttack {
		return false, errors.New("not in attack phase")
	}

	defenderTeamID := s.getOpponentTeamID(ctx, ctfRoomID, attackingTeamID)
	defenderTeam, err := s.repo.GetCTFTeam(ctx, ctfRoomID, defenderTeamID)
	if err != nil {
		return false, err
	}

	if defenderTeam.FlagFound {
		return false, errors.New("flag already found")
	}

	normSubmit := NormalizeAnswer(submittedFlag)
	normActual := NormalizeAnswer(defenderTeam.Flag)

	if subtle.ConstantTimeCompare([]byte(normSubmit), []byte(normActual)) != 1 {
		return false, nil // wrong flag
	}

	// Correct flag!
	_ = s.repo.MarkFlagFound(ctx, ctfRoomID, attackingTeamID, defenderTeamID)
	_ = s.repo.UpdateTeamScore(ctx, ctfRoomID, attackingTeamID, 500)
	_ = s.repo.UpdatePhase(ctx, ctfRoomID, PhasePatching)
	
	_ = s.TriggerPatching(ctx, ctfRoomID, defenderTeamID)

	return true, nil
}

func (s *CTFService) TriggerPatching(ctx context.Context, ctfRoomID, teamID int64) error {
	// In a real scenario we'd count past patches. Here we just pick random for simplicity.
	// Hardcode easy for now
	template := GetPatchChallenge("easy")

	challenge := &CTFPatchChallenge{
		CTFRoomID:     ctfRoomID,
		TeamID:        teamID,
		ChallengeType: template.Type,
		Difficulty:    template.Difficulty,
		Question:      template.Question,
		CorrectAnswer: template.Answer,
	}

	_, err := s.repo.CreatePatchChallenge(ctx, challenge)
	return err
}

func (s *CTFService) SubmitPatch(ctx context.Context, ctfRoomID, teamID int64, answer string, timeTaken int) (bool, error) {
	room, err := s.repo.GetCTFRoom(ctx, ctfRoomID)
	if err != nil {
		return false, err
	}
	if room.Phase != PhasePatching {
		return false, errors.New("not in patching phase")
	}

	challenge, err := s.repo.GetActivePatchChallenge(ctx, ctfRoomID, teamID)
	if err != nil {
		return false, err
	}
	if challenge == nil {
		return false, errors.New("no active challenge")
	}

	if NormalizeAnswer(answer) != NormalizeAnswer(challenge.CorrectAnswer) {
		return false, nil
	}

	err = s.repo.SubmitPatchAnswer(ctx, challenge.ID, challenge.CorrectAnswer, timeTaken)
	if err != nil {
		return false, err
	}

	bonus := 50
	if timeTaken <= 30 {
		bonus = 200
	} else if timeTaken <= 60 {
		bonus = 150
	} else if timeTaken <= 90 {
		bonus = 100
	}

	_ = s.repo.UpdateTeamScore(ctx, ctfRoomID, teamID, bonus)
	
	// Determine if we should go back to attack or finish.
	// If both flags found, finish.
	teams, _ := s.repo.GetAllCTFTeams(ctx, ctfRoomID)
	allFound := true
	for _, t := range teams {
		if !t.FlagFound {
			allFound = false
			break
		}
	}

	if allFound {
		_, _ = s.FinishCTF(ctx, ctfRoomID)
	} else {
		_ = s.repo.UpdatePhase(ctx, ctfRoomID, PhaseAttack)
	}

	return true, nil
}

func (s *CTFService) FinishCTF(ctx context.Context, ctfRoomID int64) ([]*CTFTeam, error) {
	_ = s.repo.UpdatePhase(ctx, ctfRoomID, PhaseFinished)

	teams, err := s.repo.GetAllCTFTeams(ctx, ctfRoomID)
	if err != nil {
		return nil, err
	}

	for _, t := range teams {
		// Defense bonus if flag not found
		if !t.FlagFound {
			_ = s.repo.UpdateTeamScore(ctx, ctfRoomID, t.TeamID, 300)
		}
		// In real impl, we'd add tokens bonus here.
	}

	return s.repo.GetFinalScores(ctx, ctfRoomID)
}

func (s *CTFService) GetCTFState(ctx context.Context, ctfRoomID, requestingTeamID int64) (*CTFStateResponse, error) {
	room, err := s.repo.GetCTFRoom(ctx, ctfRoomID)
	if err != nil || room == nil {
		return nil, errors.New("room not found")
	}

	teams, err := s.repo.GetAllCTFTeams(ctx, ctfRoomID)
	if err != nil {
		return nil, err
	}

	var myTeam CTFTeam
	var oppTeam CTFTeamPublicView

	for _, t := range teams {
		if t.TeamID == requestingTeamID {
			myTeam = *t
		} else {
			oppTeam = CTFTeamPublicView{
				ID:              t.ID,
				CTFRoomID:       t.CTFRoomID,
				TeamID:          t.TeamID,
				DefenseImageURL: t.DefenseImageURL,
				CipherMethod:    t.CipherMethod,
				FlagFound:       t.FlagFound,
				FlagFoundAt:     t.FlagFoundAt,
				FlagFoundBy:     t.FlagFoundBy,
				PatchCompleted:  t.PatchCompleted,
				Score:           t.Score,
			}
		}
	}

	logs, _ := s.repo.GetAttackLogs(ctx, ctfRoomID, requestingTeamID)
	
	// Create safe slice, limit to last 5 logs or all
	safeLogs := make([]CTFAttackLog, 0)
	for _, l := range logs {
		safeLogs = append(safeLogs, *l)
	}

	var patchChallenge *CTFPatchChallenge
	if room.Phase == PhasePatching {
		pc, _ := s.repo.GetActivePatchChallenge(ctx, ctfRoomID, requestingTeamID)
		if pc != nil {
			patchChallenge = pc
		}
	}

	timeLeft := 0
	if room.PhaseStartedAt != nil {
		elapsed := int(time.Since(*room.PhaseStartedAt).Seconds())
		if room.Phase == PhaseDefense {
			timeLeft = room.DefenseDurationSec - elapsed
		} else if room.Phase == PhaseAttack {
			timeLeft = room.AttackDurationSec - elapsed
		}
		if timeLeft < 0 {
			timeLeft = 0
		}
	}

	return &CTFStateResponse{
		Room:           *room,
		PhaseTimeLeft:  timeLeft,
		MyTeam:         myTeam,
		OpponentTeam:   oppTeam,
		RecentLogs:     safeLogs,
		PatchChallenge: patchChallenge,
	}, nil
}
