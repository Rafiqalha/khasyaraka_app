package auth

type RegisterRequest struct {
	Name        string `json:"name" binding:"required"`
	Username    string `json:"username" binding:"required"`
	Password    string `json:"password" binding:"required"`
	CountryID   string `json:"country_id"`
	ProvinsiID  string `json:"provinsi_id"`
	KabupatenID string `json:"kabupaten_id"`
	KecamatanID string `json:"kecamatan_id"`
}

type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type GoogleTokenRequest struct {
	IDToken string `json:"id_token" binding:"required"`
}

type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required"`
}

type AuthResponse struct {
	AccessToken        string `json:"access_token"`
	TokenType          string `json:"token_type"`
	ID                 int64  `json:"id"`
	Name               string `json:"name"`
	Username           string `json:"username"`
	IsPro              bool   `json:"is_pro"`
	MustChangePassword bool   `json:"must_change_password"`
}

type GoogleAuthResponse struct {
	ID                 int64   `json:"id"`
	Email              string  `json:"email"`
	FullName           string  `json:"full_name"`
	PictureURL         *string `json:"picture_url,omitempty"`
	AccessToken        string  `json:"access_token"`
	TokenType          string  `json:"token_type"`
	MustChangePassword bool    `json:"must_change_password"`
}

type UserResponse struct {
	ID       int64  `json:"id"`
	Email    string `json:"email"`
	FullName string `json:"full_name"`
	IsActive bool   `json:"is_active"`
}
