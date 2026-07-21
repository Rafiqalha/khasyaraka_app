// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package arena

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"math/rand"
	"time"

	"github.com/redis/go-redis/v9"
)

const (
	ArenaQueueKey  = "arena_queue_1v1"
	MatchResultKey = "match_result:%d"
)

// Lua script for atomic check-and-pop
// It iterates through the ZSET. It looks for a user that is NOT the requesting user.
// If found, removes both users from the ZSET and returns the opponent ID.
// If not found, adds the requesting user to the ZSET and returns nil.
var matchmakeScript = redis.NewScript(`
local queue_key = KEYS[1]
local req_user = ARGV[1]
local timestamp = ARGV[2]

-- Get all users in queue
local users = redis.call('ZRANGE', queue_key, 0, -1)
local opponent = nil

for i, user in ipairs(users) do
    if user ~= req_user then
        opponent = user
        break
    end
end

if opponent then
    -- Found opponent, remove both from queue
    redis.call('ZREM', queue_key, opponent)
    redis.call('ZREM', queue_key, req_user)
    return opponent
else
    -- No opponent, add requesting user to queue
    redis.call('ZADD', queue_key, timestamp, req_user)
    return nil
end
`)

// Matchmake1v1 handles the 1v1 matchmaking queue.
func (s *Service) Matchmake1v1(ctx context.Context, userID int64) (string, error) {
	if s.rdb == nil {
		return "", errors.New("redis is required for matchmaking")
	}

	// 1. Cleanup stale entries (>90 seconds old)
	cutoff := time.Now().Add(-90 * time.Second).Unix()
	s.rdb.ZRemRangeByScore(ctx, ArenaQueueKey, "-inf", fmt.Sprintf("%d", cutoff))

	// 2. Check if user already has a match result (e.g. they polled late or disconnected)
	res, err := s.rdb.Get(ctx, fmt.Sprintf(MatchResultKey, userID)).Result()
	if err == nil && res != "" {
		return res, nil
	}

	// 3. Run Lua script
	now := time.Now().Unix()
	val, err := matchmakeScript.Run(ctx, s.rdb, []string{ArenaQueueKey}, userID, now).Result()
	if err != nil && err != redis.Nil {
		return "", fmt.Errorf("lua script error: %w", err)
	}

	if val == nil {
		// Pushed to queue, wait for someone else
		return "", nil
	}

	// 4. Opponent found! Create a room
	opponentIDStr, ok := val.(string)
	if !ok {
		return "", errors.New("invalid opponent id type from lua script")
	}

	var opponentID int64
	fmt.Sscanf(opponentIDStr, "%d", &opponentID)

	room, err := s.Create1v1Room(userID, opponentID)
	if err != nil {
		return "", fmt.Errorf("failed to create 1v1 room: %w", err)
	}

	// 5. Store result for both users (expire in 5 minutes)
	s.rdb.Set(ctx, fmt.Sprintf(MatchResultKey, userID), room.Code, 5*time.Minute)
	s.rdb.Set(ctx, fmt.Sprintf(MatchResultKey, opponentID), room.Code, 5*time.Minute)

	return room.Code, nil
}

// CancelMatchmake removes the user from the queue
func (s *Service) CancelMatchmake(ctx context.Context, userID int64) error {
	if s.rdb == nil {
		return nil
	}
	return s.rdb.ZRem(ctx, ArenaQueueKey, userID).Err()
}

// GetMatchmakeStatus checks if the user has been matched
func (s *Service) GetMatchmakeStatus(ctx context.Context, userID int64) (string, error) {
	if s.rdb == nil {
		return "", errors.New("redis is required")
	}
	res, err := s.rdb.Get(ctx, fmt.Sprintf(MatchResultKey, userID)).Result()
	if err == redis.Nil {
		return "", nil // Not matched yet
	}
	return res, err
}

// Create1v1Room creates a specific 1v1 room and assigns teams
func (s *Service) Create1v1Room(user1, user2 int64) (*Room, error) {
	room := &Room{
		Code:           generateCode(),
		HostUserID:     user1,
		Title:          "Arena Duel 1v1",
		MaxTeams:       2,
		PlayersPerTeam: 1,
		TotalQuestions: 10,
		QTimeSecs:      30,
		Status:         "playing", // Auto-start
	}
	
	now := time.Now()
	room.StartedAt = &now
	room.QStartedAt = &now

	if err := s.repo.CreateRoom(room); err != nil {
		return nil, err
	}

	questions := GenerateArenaQuestions(room.ID, room.TotalQuestions)
	if err := s.repo.InsertQuestions(questions); err != nil {
		return nil, err
	}

	// Create Team 1
	team1 := &Team{RoomID: room.ID, Name: "Team Blue", Slot: 1, CaptainUserID: user1}
	if err := s.repo.CreateTeam(team1); err != nil {
		return nil, err
	}
	p1 := &Player{TeamID: team1.ID, RoomID: room.ID, UserID: user1, IsCaptain: true}
	if err := s.repo.AddPlayerToTeam(p1); err != nil {
		return nil, err
	}

	// Create Team 2
	team2 := &Team{RoomID: room.ID, Name: "Team Red", Slot: 2, CaptainUserID: user2}
	if err := s.repo.CreateTeam(team2); err != nil {
		return nil, err
	}
	p2 := &Player{TeamID: team2.ID, RoomID: room.ID, UserID: user2, IsCaptain: true}
	if err := s.repo.AddPlayerToTeam(p2); err != nil {
		return nil, err
	}

	return room, nil
}

// BotTimestamps stores the exact timestamps when a bot will "answer" correctly
type BotTimestamps struct {
	Answers map[int]int64 `json:"answers"` // map[QuestionIndex]UnixTimestamp
}

func (s *Service) CreateBotMatch(ctx context.Context, userID int64, difficulty string) (string, error) {
	// 1. Create Room
	room := &Room{
		Code:           generateCode(),
		HostUserID:     userID,
		Title:          "Arena Duel 1v1",
		MaxTeams:       2,
		PlayersPerTeam: 1,
		TotalQuestions: 10,
		QTimeSecs:      30,
		Status:         "playing",
	}
	now := time.Now()
	room.StartedAt = &now
	room.QStartedAt = &now

	// Generate Bot Timestamps
	botTS := BotTimestamps{Answers: make(map[int]int64)}
	
	// Default to medium if unknown
	accuracy := 85
	minTime := 5
	maxTime := 20
	if difficulty == "Pemula" {
		accuracy = 70
		minTime = 10
		maxTime = 25
	} else if difficulty == "Penegak" {
		accuracy = 95
		minTime = 2
		maxTime = 15
	}

	// QIndex starts at 0
	for i := 0; i < room.TotalQuestions; i++ {
		// Random chance to get it right
		if rand.Intn(100) < accuracy {
			// Random time between minTime and maxTime
			delay := minTime + rand.Intn(maxTime-minTime+1)
			botTS.Answers[i] = int64(delay)
		}
	}

	tsBytes, err := json.Marshal(botTS)
	if err == nil {
		room.BotAnswerTimestamps = tsBytes
	}

	if err := s.repo.CreateRoom(room); err != nil {
		return "", err
	}

	questions := GenerateArenaQuestions(room.ID, room.TotalQuestions)
	if err := s.repo.InsertQuestions(questions); err != nil {
		return "", err
	}

	// Create Human Team
	team1 := &Team{RoomID: room.ID, Name: "Team Blue", Slot: 1, CaptainUserID: userID}
	if err := s.repo.CreateTeam(team1); err != nil {
		return "", err
	}
	p1 := &Player{TeamID: team1.ID, RoomID: room.ID, UserID: userID, IsCaptain: true}
	if err := s.repo.AddPlayerToTeam(p1); err != nil {
		return "", err
	}

	// Create Bot Team (UserID = 0, bot user)
	botID := int64(0)
	team2 := &Team{RoomID: room.ID, Name: "Team Red", Slot: 2, CaptainUserID: botID}
	if err := s.repo.CreateTeam(team2); err != nil {
		return "", err
	}
	p2 := &Player{TeamID: team2.ID, RoomID: room.ID, UserID: botID, IsCaptain: true, FullName: "Scout_Bot_99"}
	if err := s.repo.AddPlayerToTeam(p2); err != nil {
		return "", err
	}

	// Set match result for human
	if s.rdb != nil {
		s.rdb.Set(ctx, fmt.Sprintf(MatchResultKey, userID), room.Code, 5*time.Minute)
	}

	return room.Code, nil
}
