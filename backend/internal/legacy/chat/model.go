package chat

import (
	"time"
)

type ChatRoom struct {
	ID          int64   `json:"id" db:"id"`
	RoomType    string  `json:"room_type" db:"room_type"`
	WilayahID   *string `json:"wilayah_id" db:"wilayah_id"`
	Name        string  `json:"name" db:"name"`
	MemberCount int     `json:"member_count" db:"member_count"`
}

type ChatMessage struct {
	ID        int64     `json:"id" db:"id"`
	RoomID    int64     `json:"room_id" db:"room_id"`
	UserID    int64     `json:"user_id" db:"user_id"`
	UserName  string    `json:"user_name" db:"user_name"`   // Joined from users
	UserLevel string    `json:"user_level" db:"user_level"` // Joined from users
	Content   string    `json:"content" db:"content"`
	MsgType   string    `json:"msg_type" db:"msg_type"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

type SendMessageRequest struct {
	Content string `json:"content" binding:"required,min=1,max=500"`
}

type GetMessagesResponse struct {
	Messages []ChatMessage `json:"messages"`
	HasMore  bool          `json:"has_more"`
}

type UserChatRooms struct {
	Kecamatan *ChatRoom `json:"kecamatan"`
	Kabupaten *ChatRoom `json:"kabupaten"`
	Provinsi  *ChatRoom `json:"provinsi"`
	Negara    *ChatRoom `json:"negara"`
	Global    *ChatRoom `json:"global"`
	Nasional  *ChatRoom `json:"nasional"`
}
