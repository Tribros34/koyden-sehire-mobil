package auth

import (
	"strings"

	"github.com/jmoiron/sqlx"
	apperrors "github.com/koydensehire/backend/pkg/errors"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) FindByPhone(phone string) (*User, error) {
	var u User
	err := r.db.Get(&u, "SELECT * FROM users WHERE phone = $1", phone)
	if err != nil {
		return nil, apperrors.ErrNotFound
	}
	return &u, nil
}

// CreateCustomer inserts a new row with role='customer', returning the created user.
// Maps DB unique-violation errors to apperrors.ErrConflict so the handler can map to 409.
func (r *Repository) CreateCustomer(fullName, phone, email, passwordHash string) (*User, error) {
	var u User
	err := r.db.Get(&u, `
		INSERT INTO users (
			full_name, phone, email, password_hash,
			role, status, phone_verified, phone_verified_at
		) VALUES ($1, $2, $3, $4, 'customer', 'active', true, NOW())
		RETURNING *
	`, fullName, phone, email, passwordHash)
	if err != nil {
		msg := err.Error()
		if strings.Contains(msg, "users_phone_key") {
			return nil, apperrors.New("PHONE_TAKEN", "Bu telefon numarası zaten kayıtlı", 409)
		}
		if strings.Contains(msg, "users_email_key") {
			return nil, apperrors.New("EMAIL_TAKEN", "Bu e-posta zaten kayıtlı", 409)
		}
		return nil, apperrors.ErrInternal
	}
	return &u, nil
}
