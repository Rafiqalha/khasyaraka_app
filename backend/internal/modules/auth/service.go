package auth

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type GoogleUserInfo struct {
	Sub     string `json:"sub"`
	Email   string `json:"email"`
	Name    string `json:"name"`
	Picture string `json:"picture"`
}

type Service struct {
	repo      *Repository
	jwtSecret string
	jwtExpiry time.Duration
}

func NewService(repo *Repository, jwtSecret string, jwtExpiryMinutes int) *Service {
	return &Service{
		repo:      repo,
		jwtSecret: jwtSecret,
		jwtExpiry: time.Duration(jwtExpiryMinutes) * time.Minute,
	}
}

func (s *Service) hashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", fmt.Errorf("hash password: %w", err)
	}
	return string(bytes), nil
}

func (s *Service) verifyPassword(plain, hashed string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hashed), []byte(plain)) == nil
}

func (s *Service) createAccessToken(userID int64, isSuperuser bool) (string, error) {
	now := time.Now()
	claims := jwt.MapClaims{
		"sub":          fmt.Sprintf("%d", userID),
		"is_superuser": isSuperuser,
		"exp":          now.Add(s.jwtExpiry).Unix(),
		"iat":          now.Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.jwtSecret))
}

func (s *Service) verifyGoogleToken(idToken string) (*GoogleUserInfo, error) {
	resp, err := http.Get(fmt.Sprintf("https://oauth2.googleapis.com/tokeninfo?id_token=%s", idToken))
	if err != nil {
		return nil, fmt.Errorf("google token verification request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("google token verification failed: status %d", resp.StatusCode)
	}

	var info GoogleUserInfo
	if err := json.NewDecoder(resp.Body).Decode(&info); err != nil {
		return nil, fmt.Errorf("decode google response: %w", err)
	}

	if info.Email == "" {
		return nil, fmt.Errorf("invalid google token: no email returned")
	}

	return &info, nil
}

func (s *Service) Register(name, username, password string) (*AuthResponse, error) {
	email := username

	existing, err := s.repo.GetByEmail(email)
	if err != nil {
		return nil, fmt.Errorf("check existing user: %w", err)
	}
	if existing != nil {
		return nil, fmt.Errorf("email already registered: %s", email)
	}

	hashed, err := s.hashPassword(password)
	if err != nil {
		return nil, err
	}

	user, err := s.repo.Create(email, hashed, name, nil, true)
	if err != nil {
		return nil, err
	}

	token, err := s.createAccessToken(user.ID, false)
	if err != nil {
		return nil, err
	}

	return &AuthResponse{
		AccessToken:        token,
		TokenType:          "bearer",
		ID:                 user.ID,
		Name:               user.FullName.String,
		Username:            user.Email,
		IsPro:              false,
		MustChangePassword: user.MustChangePassword,
	}, nil
}

func (s *Service) Login(username, password string) (*AuthResponse, error) {
	email := username

	user, err := s.repo.GetByEmail(email)
	if err != nil {
		return nil, fmt.Errorf("find user: %w", err)
	}
	if user == nil {
		return nil, fmt.Errorf("invalid email or password")
	}

	if !s.verifyPassword(password, user.HashedPassword) {
		return nil, fmt.Errorf("invalid email or password")
	}

	if !user.IsActive {
		return nil, fmt.Errorf("user account is disabled")
	}

	token, err := s.createAccessToken(user.ID, user.IsSuperuser)
	if err != nil {
		return nil, err
	}

	return &AuthResponse{
		AccessToken:        token,
		TokenType:          "bearer",
		ID:                 user.ID,
		Name:               user.FullName.String,
		Username:            user.Email,
		IsPro:              false,
		MustChangePassword: user.MustChangePassword,
	}, nil
}

func (s *Service) GoogleSignIn(idToken string) (*GoogleAuthResponse, error) {
	info, err := s.verifyGoogleToken(idToken)
	if err != nil {
		return nil, err
	}

	user, err := s.repo.GetByEmail(info.Email)
	if err != nil {
		return nil, fmt.Errorf("find user: %w", err)
	}

	if user != nil {
		if !user.IsActive {
			return nil, fmt.Errorf("user account is disabled")
		}

		if info.Picture != "" && (user.PictureURL == nil || user.PictureURL != nil && *user.PictureURL == "") {
			if err := s.repo.UpdatePictureURL(user.ID, info.Picture); err != nil {
				return nil, fmt.Errorf("update picture: %w", err)
			}
			user.PictureURL = &info.Picture
		}

		token, err := s.createAccessToken(user.ID, user.IsSuperuser)
		if err != nil {
			return nil, err
		}

		return &GoogleAuthResponse{
			ID:                 user.ID,
			Email:              user.Email,
			FullName:           user.FullName.String,
			PictureURL:         user.PictureURL,
			AccessToken:        token,
			TokenType:          "bearer",
			MustChangePassword: user.MustChangePassword,
		}, nil
	}

	hashed, err := s.hashPassword(info.Sub)
	if err != nil {
		return nil, err
	}

	newUser, err := s.repo.Create(info.Email, hashed, info.Name, &info.Picture, true)
	if err != nil {
		return nil, err
	}

	token, err := s.createAccessToken(newUser.ID, false)
	if err != nil {
		return nil, err
	}

	return &GoogleAuthResponse{
		ID:                 newUser.ID,
		Email:              newUser.Email,
		FullName:           newUser.FullName.String,
		PictureURL:         newUser.PictureURL,
		AccessToken:        token,
		TokenType:          "bearer",
		MustChangePassword: newUser.MustChangePassword,
	}, nil
}

func (s *Service) ChangePassword(userID int64, oldPassword, newPassword string) error {
	user, err := s.repo.GetByID(userID)
	if err != nil {
		return fmt.Errorf("find user: %w", err)
	}
	if user == nil {
		return fmt.Errorf("user not found")
	}

	if !s.verifyPassword(oldPassword, user.HashedPassword) {
		return fmt.Errorf("password lama salah")
	}

	if len(newPassword) < 6 {
		return fmt.Errorf("password baru minimal 6 karakter")
	}

	hashed, err := s.hashPassword(newPassword)
	if err != nil {
		return err
	}

	return s.repo.UpdatePassword(userID, hashed)
}
