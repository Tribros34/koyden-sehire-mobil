package auth

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	apperrors "github.com/koydensehire/backend/pkg/errors"
	"github.com/redis/go-redis/v9"
	"golang.org/x/crypto/bcrypt"
)

type Service struct {
	repo                *Repository
	rdb                 *redis.Client
	jwtSecret           string
	jwtExpiry           time.Duration
	refreshTokenExpiry  time.Duration
}

func NewService(repo *Repository, rdb *redis.Client, jwtSecret string, jwtExpiry, refreshTokenExpiry time.Duration) *Service {
	return &Service{
		repo:               repo,
		rdb:                rdb,
		jwtSecret:          jwtSecret,
		jwtExpiry:          jwtExpiry,
		refreshTokenExpiry: refreshTokenExpiry,
	}
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

	refreshToken, err := s.issueRefreshToken(context.Background(), user.ID)
	if err != nil {
		return nil, apperrors.ErrInternal
	}

	return &LoginResponse{
		AccessToken:  token,
		RefreshToken: refreshToken,
		User: UserInfo{
			ID:     user.ID,
			Name:   user.FullName,
			Phone:  user.Phone,
			Role:   user.Role,
			Status: user.Status,
		},
	}, nil
}

// RegisterCustomer creates a new 'customer' account.
// Preconditions:
//   - The phone must have a fresh otp_verified:{phone} marker in Redis (set by otp.Verify).
//     We consume (delete) it on success so the same OTP cannot be reused.
//   - Phone / email must be unique (enforced at DB level; mapped to 409 by repo).
func (s *Service) RegisterCustomer(req *RegisterCustomerRequest) (*LoginResponse, error) {
	if !validPhone(req.Phone) {
		return nil, apperrors.New("INVALID_PHONE", "Geçersiz telefon numarası formatı", 400)
	}

	ctx := context.Background()
	verifiedKey := fmt.Sprintf("otp_verified:%s", req.Phone)

	exists, err := s.rdb.Exists(ctx, verifiedKey).Result()
	if err != nil {
		return nil, apperrors.ErrInternal
	}
	if exists == 0 {
		// Either OTP was never verified or the 30-min window expired.
		return nil, apperrors.New("OTP_NOT_VERIFIED", "Telefon doğrulaması gerekli", 400)
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), 12)
	if err != nil {
		return nil, apperrors.ErrInternal
	}

	user, err := s.repo.CreateCustomer(req.FullName, req.Phone, req.Email, string(hash))
	if err != nil {
		return nil, err
	}

	// Consume the OTP marker so this same verification can't be reused for
	// another registration attempt.
	s.rdb.Del(ctx, verifiedKey)

	token, err := s.generateToken(user)
	if err != nil {
		return nil, apperrors.ErrInternal
	}

	refreshToken, err := s.issueRefreshToken(ctx, user.ID)
	if err != nil {
		return nil, apperrors.ErrInternal
	}

	return &LoginResponse{
		AccessToken:  token,
		RefreshToken: refreshToken,
		User: UserInfo{
			ID:     user.ID,
			Name:   user.FullName,
			Phone:  user.Phone,
			Role:   user.Role,
			Status: user.Status,
		},
	}, nil
}

// Refresh validates the given refresh token, issues a new access token and a
// rotated refresh token (old token is deleted), and returns a full LoginResponse.
func (s *Service) Refresh(req *RefreshRequest) (*LoginResponse, error) {
	ctx := context.Background()
	key := refreshKey(req.RefreshToken)

	userID, err := s.rdb.Get(ctx, key).Result()
	if err != nil {
		return nil, apperrors.New("INVALID_REFRESH_TOKEN", "Oturum süresi doldu, lütfen tekrar giriş yapın", 401)
	}

	user, err := s.repo.FindByID(userID)
	if err != nil {
		return nil, apperrors.New("INVALID_REFRESH_TOKEN", "Oturum süresi doldu, lütfen tekrar giriş yapın", 401)
	}

	if user.Status == "suspended" {
		return nil, apperrors.New("ACCOUNT_SUSPENDED", "Hesabınız askıya alınmıştır", 403)
	}

	// Token rotation: delete the old refresh token first.
	s.rdb.Del(ctx, key)

	accessToken, err := s.generateToken(user)
	if err != nil {
		return nil, apperrors.ErrInternal
	}

	newRefreshToken, err := s.issueRefreshToken(ctx, user.ID)
	if err != nil {
		return nil, apperrors.ErrInternal
	}

	return &LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
		User: UserInfo{
			ID:     user.ID,
			Name:   user.FullName,
			Phone:  user.Phone,
			Role:   user.Role,
			Status: user.Status,
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

func refreshKey(token string) string {
	return fmt.Sprintf("refresh_token:%s", token)
}

func (s *Service) issueRefreshToken(ctx context.Context, userID string) (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	token := hex.EncodeToString(b)
	if err := s.rdb.Set(ctx, refreshKey(token), userID, s.refreshTokenExpiry).Err(); err != nil {
		return "", err
	}
	return token, nil
}

// validPhone matches the same 05XXXXXXXXX format enforced by the OTP service,
// so we never accept a registration phone that the OTP flow couldn't have verified.
func validPhone(phone string) bool {
	if len(phone) != 11 {
		return false
	}
	if phone[0] != '0' || phone[1] != '5' {
		return false
	}
	for i := 2; i < 11; i++ {
		c := phone[i]
		if c < '0' || c > '9' {
			return false
		}
	}
	return true
}
