package auth

type RegisterRequest struct {
	Name     string `json:"name" binding:"required"`
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type GoogleTokenRequest struct {
	IDToken string `json:"id_token" binding:"required"`
}

type AuthResponse struct {
	AccessToken string `json:"access_token"`
	TokenType   string `json:"token_type"`
	ID          int64  `json:"id"`
	Name        string `json:"name"`
	Username    string `json:"username"`
	IsPro       bool   `json:"is_pro"`
}

type GoogleAuthResponse struct {
	ID          int64   `json:"id"`
	Email       string  `json:"email"`
	FullName    string  `json:"full_name"`
	PictureURL  *string `json:"picture_url,omitempty"`
	AccessToken string  `json:"access_token"`
	TokenType   string  `json:"token_type"`
}

type UserResponse struct {
	ID       int64  `json:"id"`
	Email    string `json:"email"`
	FullName string `json:"full_name"`
	IsActive bool   `json:"is_active"`
}
