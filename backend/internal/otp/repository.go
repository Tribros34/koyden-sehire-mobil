package otp

import (
	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) InsertAudit(phone, purpose, ip, userAgent string) error {
	_, err := r.db.Exec(`
		INSERT INTO otp_verifications (phone, purpose, ip_address, user_agent)
		VALUES ($1, $2, $3, $4)
	`, phone, purpose, ip, userAgent)
	return err
}

func (r *Repository) MarkVerified(phone string) error {
	_, err := r.db.Exec(`
		UPDATE otp_verifications
		SET verified = true, verified_at = NOW()
		WHERE id = (
			SELECT id FROM otp_verifications
			WHERE phone = $1 AND verified = false
			ORDER BY created_at DESC
			LIMIT 1
		)
	`, phone)
	return err
}
