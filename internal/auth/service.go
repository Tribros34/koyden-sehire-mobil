package auth

import (
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	apperrors "github.com/koydensehire/backend/pkg/errors"
	"golang.org/x/crypto/bcrypt"
)

type Service struct {
	repo      *Repository
	jwtSecret string
	jwtExpiry time.Duration
}

func NewService(repo *Repository, jwtSecret string, jwtExpiry time.Duration) *Service {
	return &Service{repo: repo, jwtSecret: jwtSecret, jwtExpiry: jwtExpiry}
}

func (s *Service) Login(req *LoginRequest) (*LoginResponse, error) {
	user, err := s.repo.FindByPhone(req.Phone)
	if err != nil {
		return nil, apperrors.New("INVALID_CREDENTIALS", "Telefon numarası veya şifre hatalı", 401)
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return nil, apperrors.New("INVALID_CREDENTIALS", "Telefon numarası veya şifre hatalı", 401)
	}

	if user.Status == "suspended" {
		return nil, apperrors.New("ACCOUNT_SUSPENDED", "Hesabınız askıya alınmıştır", 403)
	}

	token, err := s.generateToken(user)
	if err != nil {
		return nil, apperrors.ErrInternal
	}

	return &LoginResponse{
		AccessToken: token,
		User: UserInfo{
			ID:    user.ID,
			Name:  user.FullName,
			Phone: user.Phone,
			Role:  user.Role,
		},
	}, nil
}

func (s *Service) generateToken(user *User) (string, error) {
	claims := jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(s.jwtExpiry).Unix(),
		"iat":     time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString([]byte(s.jwtSecret))
	if err != nil {
		return "", fmt.Errorf("signing token: %w", err)
	}
	return signed, nil
}
