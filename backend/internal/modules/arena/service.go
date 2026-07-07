package arena

import (
	"encoding/json"
	"errors"
	"fmt"
	"math/rand"
	"strings"
	"time"
	
	"github.com/redis/go-redis/v9"
)

type Service struct {
	repo *Repository
	rdb  *redis.Client
}

func NewService(repo *Repository, rdb *redis.Client) *Service {
	return &Service{repo: repo, rdb: rdb}
}

// generateCode creates a random 5-character alphanumeric code e.g. PRDA7XYZ
func generateCode() string {
	const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	b := make([]byte, 5)
	for i := range b {
		b[i] = charset[rand.Intn(len(charset))]
	}
	return "PRD" + string(b)
}

func (s *Service) CreateRoom(hostID int64) (*Room, error) {
	room := &Room{
		Code:           generateCode(),
		HostUserID:     hostID,
		Title:          "Arena Cyber-Scout",
		MaxTeams:       2,
		PlayersPerTeam: 5,
		TotalQuestions: 10,
		QTimeSecs:      30,
		Status:         "waiting",
	}

	err := s.repo.CreateRoom(room)
	if err != nil {
		return nil, fmt.Errorf("create room: %w", err)
	}

	// Generate 10 random questions for this room
	questions := GenerateArenaQuestions(room.ID, room.TotalQuestions)
	if err := s.repo.InsertQuestions(questions); err != nil {
		return nil, fmt.Errorf("insert questions: %w", err)
	}

	return room, nil
}

func (s *Service) GetRoomState(code string, userID int64) (*RoomState, error) {
	room, err := s.repo.GetRoomByCode(code)
	if err != nil {
		return nil, err
	}
	if room == nil {
		return nil, errors.New("room not found")
	}

	// Fetch teams for leaderboard
	teams, err := s.repo.GetTeamsByRoomID(room.ID)
	if err != nil {
		return nil, err
	}
	leaderboard := make([]TeamScore, 0, len(teams))
	for _, t := range teams {
		leaderboard = append(leaderboard, TeamScore{
			TeamName: t.Name,
			Score:    t.TotalScore,
		})
	}

	state := &RoomState{
		Status:      room.Status,
		Leaderboard: leaderboard,
	}

	if room.Status == "playing" {
		// Check auto-advance
		now := time.Now()
		elapsedSecs := 0
		if room.QStartedAt != nil {
			elapsedSecs = int(now.Sub(*room.QStartedAt).Seconds())
		}

		if elapsedSecs >= room.QTimeSecs {
			// Time is up, advance question
			room.CurrentQIndex++
			room.QStartedAt = &now
			if room.CurrentQIndex >= room.TotalQuestions {
				room.Status = "finished"
				room.FinishedAt = &now
			}
			if err := s.repo.UpdateRoomState(room); err != nil {
				return nil, err
			}
			state.Status = room.Status
			elapsedSecs = 0
		}

		if room.Status == "playing" {
			q, err := s.repo.GetQuestionByOrder(room.ID, room.CurrentQIndex+1)
			if err != nil {
				return nil, err
			}
			if q != nil {
				state.CurrentQuestion = &QuestionState{
					Index:             q.QOrder,
					Total:             room.TotalQuestions,
					Text:              q.QuestionText,
					Type:              q.QuestionType,
					Payload:           q.Payload,
					TimeRemainingSecs: room.QTimeSecs - elapsedSecs,
				}

				// Check if user already answered
				player, err := s.repo.GetPlayerInRoom(room.ID, userID)
				if err == nil && player != nil {
					state.MyTeamScore = player.Score // Or team score if needed
					answered, _ := s.repo.HasAnswered(q.ID, player.ID)
					state.AlreadyAnswered = answered
				}

				// Bot Auto-Answer Logic
				if len(room.BotAnswerTimestamps) > 0 {
					var botTS BotTimestamps
					if err := json.Unmarshal(room.BotAnswerTimestamps, &botTS); err == nil {
						if targetTime, exists := botTS.Answers[q.QOrder-1]; exists {
							if int64(elapsedSecs) >= targetTime {
								// Check if Bot exists in room
								teams, _ := s.repo.GetTeamsByRoomID(room.ID)
								var botPlayerID, botTeamID int64
								for _, t := range teams {
									if t.CaptainUserID == -1 {
										botTeamID = t.ID
										break
									}
								}
								if botTeamID != 0 {
									// Find bot player
									players, _ := s.repo.GetPlayersByRoomID(room.ID)
									for _, p := range players {
										if p.UserID == -1 {
											botPlayerID = p.ID
											break
										}
									}
									if botPlayerID != 0 {
										// Check if bot already answered
										botAns, _ := s.repo.HasAnswered(q.ID, botPlayerID)
										if !botAns {
											// Score based on time (closer to 0 is better, max points = q.Points)
											timeRatio := 1.0 - (float64(targetTime) / float64(room.QTimeSecs))
											if timeRatio < 0.1 {
												timeRatio = 0.1
											}
											pointsEarned := int(float64(q.Points) * timeRatio)
											
											botAnsObj := &Answer{
												RoomID:       room.ID,
												QuestionID:   q.ID,
												TeamID:       botTeamID,
												PlayerID:     botPlayerID,
												Answer:       q.CorrectAnswer,
												IsCorrect:    true,
												TimeTakenMs:  int(targetTime * 1000),
												PointsEarned: pointsEarned,
											}
											if err := s.repo.SaveAnswer(botAnsObj); err == nil {
												_ = s.repo.UpdateScores(botTeamID, botPlayerID, pointsEarned)
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	return state, nil
}

func (s *Service) StartRoom(code string, hostID int64) error {
	room, err := s.repo.GetRoomByCode(code)
	if err != nil {
		return err
	}
	if room == nil {
		return errors.New("room not found")
	}
	if room.HostUserID != hostID {
		return errors.New("only host can start the room")
	}
	if room.Status != "waiting" {
		return errors.New("room already started or finished")
	}

	teams, err := s.repo.GetTeamsByRoomID(room.ID)
	if err != nil {
		return err
	}
	if len(teams) < 2 {
		return errors.New("minimum 2 teams required to start")
	}

	now := time.Now()
	room.Status = "playing"
	room.CurrentQIndex = 0
	room.StartedAt = &now
	room.QStartedAt = &now

	return s.repo.UpdateRoomState(room)
}

func (s *Service) JoinTeam(code string, slot int, userID int64) error {
	room, err := s.repo.GetRoomByCode(code)
	if err != nil || room == nil {
		return errors.New("room not found")
	}
	if room.Status != "waiting" {
		return errors.New("cannot join, room already started")
	}

	teams, err := s.repo.GetTeamsByRoomID(room.ID)
	if err != nil {
		return err
	}

	var targetTeam *Team
	for i := range teams {
		if teams[i].Slot == slot {
			targetTeam = &teams[i]
			break
		}
	}

	if targetTeam == nil {
		return errors.New("team slot not found")
	}

	// Check if already in room
	p, _ := s.repo.GetPlayerInRoom(room.ID, userID)
	if p != nil {
		return errors.New("you are already in this room")
	}

	player := &Player{
		TeamID:    targetTeam.ID,
		RoomID:    room.ID,
		UserID:    userID,
		IsCaptain: false,
	}
	return s.repo.AddPlayerToTeam(player)
}

func (s *Service) CreateTeam(code string, req CreateTeamRequest, userID int64) error {
	room, err := s.repo.GetRoomByCode(code)
	if err != nil || room == nil {
		return errors.New("room not found")
	}
	if room.Status != "waiting" {
		return errors.New("cannot create team, room already started")
	}

	teams, err := s.repo.GetTeamsByRoomID(room.ID)
	if err != nil {
		return err
	}

	if len(teams) >= room.MaxTeams {
		return errors.New("room is full, max teams reached")
	}

	// Find empty slot
	usedSlots := make(map[int]bool)
	for _, t := range teams {
		usedSlots[t.Slot] = true
	}
	var freeSlot = -1
	for i := 1; i <= room.MaxTeams; i++ {
		if !usedSlots[i] {
			freeSlot = i
			break
		}
	}

	if freeSlot == -1 {
		return errors.New("no empty slots available")
	}

	// Check if already in room
	p, _ := s.repo.GetPlayerInRoom(room.ID, userID)
	if p != nil {
		return errors.New("you are already in this room")
	}

	team := &Team{
		RoomID:        room.ID,
		Name:          strings.TrimSpace(req.Name),
		Slot:          freeSlot,
		CaptainUserID: userID,
	}
	if err := s.repo.CreateTeam(team); err != nil {
		return err
	}

	player := &Player{
		TeamID:    team.ID,
		RoomID:    room.ID,
		UserID:    userID,
		IsCaptain: true,
	}
	return s.repo.AddPlayerToTeam(player)
}

func (s *Service) SubmitAnswer(code string, userID int64, req AnswerRequest) (*Answer, error) {
	room, err := s.repo.GetRoomByCode(code)
	if err != nil || room == nil {
		return nil, errors.New("room not found")
	}
	if room.Status != "playing" {
		return nil, errors.New("room is not playing")
	}

	player, err := s.repo.GetPlayerInRoom(room.ID, userID)
	if err != nil || player == nil {
		return nil, errors.New("you are not in this room")
	}

	q, err := s.repo.GetQuestionByOrder(room.ID, room.CurrentQIndex+1)
	if err != nil || q == nil {
		return nil, errors.New("question not found")
	}

	answered, _ := s.repo.HasAnswered(q.ID, player.ID)
	if answered {
		return nil, errors.New("already answered this question")
	}

	now := time.Now()
	elapsedSecs := 0
	if room.QStartedAt != nil {
		elapsedSecs = int(now.Sub(*room.QStartedAt).Seconds())
	}
	if elapsedSecs >= room.QTimeSecs {
		return nil, errors.New("time is up for this question")
	}

	// Evaluate answer
	isCorrect := strings.EqualFold(strings.TrimSpace(req.Answer), q.CorrectAnswer)
	
	pointsEarned := 0
	if isCorrect {
		// Base points (100) + speed bonus
		speedBonus := 0
		if elapsedSecs < room.QTimeSecs {
			timeRemaining := room.QTimeSecs - elapsedSecs
			// Max bonus is 100 points
			speedBonus = int((float64(timeRemaining) / float64(room.QTimeSecs)) * 100.0)
		}
		pointsEarned = q.Points + speedBonus
	}

	ans := &Answer{
		RoomID:       room.ID,
		QuestionID:   q.ID,
		TeamID:       player.TeamID,
		PlayerID:     player.ID,
		Answer:       req.Answer,
		IsCorrect:    isCorrect,
		TimeTakenMs:  elapsedSecs * 1000,
		PointsEarned: pointsEarned,
	}

	if err := s.repo.SaveAnswer(ans); err != nil {
		return nil, err
	}

	if pointsEarned > 0 {
		if err := s.repo.UpdateScores(player.TeamID, player.ID, pointsEarned); err != nil {
			return nil, err
		}
	}

	return ans, nil
}
