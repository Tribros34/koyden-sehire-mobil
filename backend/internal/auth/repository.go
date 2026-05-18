package auth

import (
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
