package chat

import (
	"context"
	"errors"

	"github.com/redis/go-redis/v9"
)

type Service struct {
	repo *Repository
	hub  *WsHub
}

func NewService(repo *Repository, rdb *redis.Client) *Service {
	hub := NewWsHub(rdb)
	go hub.Run()
	return &Service{
		repo: repo,
		hub:  hub,
	}
}

func (s *Service) GetUserRooms(ctx context.Context, userID int64) (*UserChatRooms, error) {
	return s.repo.GetUserRooms(ctx, userID)
}

func (s *Service) SendMessage(ctx context.Context, userID, roomID int64, req SendMessageRequest) (*ChatMessage, error) {
	cleanContent, isClean := ModerateContent(req.Content)
	if !isClean {
		return nil, errors.New("pesan tidak sesuai komunitas Pramuka")
	}

	rooms, err := s.repo.GetUserRooms(ctx, userID)
	if err != nil {
		return nil, err
	}
	
	belongsToRoom := false
	if rooms.Nasional != nil && rooms.Nasional.ID == roomID {
		belongsToRoom = true
	} else if rooms.Provinsi != nil && rooms.Provinsi.ID == roomID {
		belongsToRoom = true
	} else if rooms.Kabupaten != nil && rooms.Kabupaten.ID == roomID {
		belongsToRoom = true
	} else if rooms.Kecamatan != nil && rooms.Kecamatan.ID == roomID {
		belongsToRoom = true
	}

	if !belongsToRoom {
		return nil, errors.New("kamu tidak tergabung di room ini")
	}

	msg, err := s.repo.SendMessage(ctx, roomID, userID, cleanContent, "text")
	if err != nil {
		return nil, err
	}

	s.hub.BroadcastToRoom(roomID, msg)

	return msg, nil
}

func (s *Service) GetMessages(ctx context.Context, userID, roomID int64, beforeID int64, limit int) ([]ChatMessage, bool, error) {
	rooms, err := s.repo.GetUserRooms(ctx, userID)
	if err != nil {
		return nil, false, err
	}
	
	belongsToRoom := false
	if rooms.Nasional != nil && rooms.Nasional.ID == roomID {
		belongsToRoom = true
	} else if rooms.Provinsi != nil && rooms.Provinsi.ID == roomID {
		belongsToRoom = true
	} else if rooms.Kabupaten != nil && rooms.Kabupaten.ID == roomID {
		belongsToRoom = true
	} else if rooms.Kecamatan != nil && rooms.Kecamatan.ID == roomID {
		belongsToRoom = true
	}

	if !belongsToRoom {
		return nil, false, errors.New("kamu tidak tergabung di room ini")
	}

	msgs, err := s.repo.GetMessages(ctx, roomID, beforeID, limit+1)
	if err != nil {
		return nil, false, err
	}

	hasMore := false
	if len(msgs) > limit {
		hasMore = true
		msgs = msgs[1:] 
	}

	return msgs, hasMore, nil
}

func (s *Service) GetRoomInfo(ctx context.Context, roomID int64) (*ChatRoom, error) {
	var room ChatRoom
	err := s.repo.db.GetContext(ctx, &room, `SELECT id, room_type, wilayah_id, name, member_count FROM chat_rooms WHERE id = $1`, roomID)
	return &room, err
}

func (s *Service) SendSystemMessage(ctx context.Context, roomID int64, content string) error {
	msg, err := s.repo.SendMessage(ctx, roomID, 0, content, "system")
	if err != nil {
		return err
	}
	msg.UserName = "Sistem"
	msg.UserLevel = "Admin"
	s.hub.BroadcastToRoom(roomID, msg)
	return nil
}

func (s *Service) EnsureRoomsForUser(ctx context.Context, userID int64, kecID, kecName, kabID, kabName, provID, provName string) error {
	// Kecamatan
	if _, err := s.repo.EnsureRoomExists(ctx, "kecamatan", &kecID, "Pramuka "+kecName); err != nil {
		return err
	}
	// Kabupaten
	if _, err := s.repo.EnsureRoomExists(ctx, "kabupaten", &kabID, "Pramuka "+kabName); err != nil {
		return err
	}
	// Provinsi
	if _, err := s.repo.EnsureRoomExists(ctx, "provinsi", &provID, "Pramuka "+provName); err != nil {
		return err
	}
	// Nasional is created by migration
	return nil
}
