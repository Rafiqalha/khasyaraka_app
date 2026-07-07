package chat

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) EnsureRoomExists(ctx context.Context, roomType string, wilayahID *string, name string) (*ChatRoom, error) {
	var id int64
	err := r.db.QueryRowContext(ctx, `
		INSERT INTO chat_rooms (room_type, wilayah_id, name)
		VALUES ($1, $2, $3)
		ON CONFLICT (room_type, wilayah_id) DO UPDATE SET name = EXCLUDED.name
		RETURNING id
	`, roomType, wilayahID, name).Scan(&id)

	if err != nil {
		if err == sql.ErrNoRows {
			return r.GetRoomByWilayah(ctx, roomType, wilayahID)
		}
		return nil, fmt.Errorf("ensure room exists: %w", err)
	}

	return &ChatRoom{
		ID:        id,
		RoomType:  roomType,
		WilayahID: wilayahID,
		Name:      name,
	}, nil
}

func (r *Repository) GetRoomByWilayah(ctx context.Context, roomType string, wilayahID *string) (*ChatRoom, error) {
	var room ChatRoom
	var err error
	if wilayahID == nil {
		err = r.db.GetContext(ctx, &room, `SELECT id, room_type, wilayah_id, name, member_count FROM chat_rooms WHERE room_type = $1 AND wilayah_id IS NULL`, roomType)
	} else {
		err = r.db.GetContext(ctx, &room, `SELECT id, room_type, wilayah_id, name, member_count FROM chat_rooms WHERE room_type = $1 AND wilayah_id = $2`, roomType, wilayahID)
	}
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errors.New("room not found")
		}
		return nil, err
	}
	return &room, nil
}

func (r *Repository) SendMessage(ctx context.Context, roomID, userID int64, content, msgType string) (*ChatMessage, error) {
	var msg ChatMessage
	err := r.db.QueryRowContext(ctx, `
		INSERT INTO chat_messages (room_id, user_id, content, msg_type)
		VALUES ($1, $2, $3, $4)
		RETURNING id, room_id, user_id, content, msg_type, created_at
	`, roomID, userID, content, msgType).Scan(
		&msg.ID, &msg.RoomID, &msg.UserID, &msg.Content, &msg.MsgType, &msg.CreatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("insert message: %w", err)
	}

	err = r.db.QueryRowContext(ctx, `SELECT full_name, COALESCE(hack_level, 'Siaga') FROM users WHERE id = $1`, userID).Scan(&msg.UserName, &msg.UserLevel)
	if err != nil {
		return nil, fmt.Errorf("get user for message: %w", err)
	}

	return &msg, nil
}

func (r *Repository) GetMessages(ctx context.Context, roomID int64, beforeID int64, limit int) ([]ChatMessage, error) {
	if limit > 50 {
		limit = 50
	}
	
	query := `
		SELECT m.id, m.room_id, m.user_id, u.full_name as user_name, COALESCE(u.hack_level, 'Siaga') as user_level, 
		       m.content, m.msg_type, m.created_at
		FROM chat_messages m
		JOIN users u ON m.user_id = u.id
		WHERE m.room_id = $1
	`
	args := []interface{}{roomID}

	if beforeID > 0 {
		query += ` AND m.id < $2`
		args = append(args, beforeID)
	}

	query += ` ORDER BY m.created_at DESC LIMIT $` + fmt.Sprintf("%d", len(args)+1)
	args = append(args, limit)

	var msgs []ChatMessage
	err := r.db.SelectContext(ctx, &msgs, query, args...)
	if err != nil {
		return nil, err
	}

	for i, j := 0, len(msgs)-1; i < j; i, j = i+1, j-1 {
		msgs[i], msgs[j] = msgs[j], msgs[i]
	}

	return msgs, nil
}

func (r *Repository) GetUserRooms(ctx context.Context, userID int64) (*UserChatRooms, error) {
	var kec, kab, prov sql.NullString
	err := r.db.QueryRowContext(ctx, `SELECT kecamatan_id, kabupaten_id, provinsi_id FROM users WHERE id = $1`, userID).Scan(&kec, &kab, &prov)
	if err != nil {
		return nil, err
	}

	var rooms UserChatRooms
	
	nas, _ := r.GetRoomByWilayah(ctx, "nasional", nil)
	rooms.Nasional = nas

	if kec.Valid {
		kecID := kec.String
		kRoom, _ := r.GetRoomByWilayah(ctx, "kecamatan", &kecID)
		rooms.Kecamatan = kRoom
	}
	if kab.Valid {
		kabID := kab.String
		kRoom, _ := r.GetRoomByWilayah(ctx, "kabupaten", &kabID)
		rooms.Kabupaten = kRoom
	}
	if prov.Valid {
		provID := prov.String
		pRoom, _ := r.GetRoomByWilayah(ctx, "provinsi", &provID)
		rooms.Provinsi = pRoom
	}

	return &rooms, nil
}
