package invites

import "time"

type InviteCode struct {
	ID          string     `db:"id" json:"id"`
	Code        string     `db:"code" json:"code"`
	OwnerUserID string     `db:"owner_user_id" json:"owner_user_id"`
	OwnerType   string     `db:"owner_type" json:"owner_type"`
	MaxUses     int        `db:"max_uses" json:"max_uses"`
	UsedCount   int        `db:"used_count" json:"used_count"`
	IsActive    bool       `db:"is_active" json:"is_active"`
	ExpiresAt   *time.Time `db:"expires_at" json:"expires_at"`
	CreatedAt   time.Time  `db:"created_at" json:"created_at"`
	UpdatedAt   time.Time  `db:"updated_at" json:"updated_at"`
}

type Invitation struct {
	ID            string    `db:"id" json:"id"`
	InviteCodeID  string    `db:"invite_code_id" json:"invite_code_id"`
	InviterUserID string    `db:"inviter_user_id" json:"inviter_user_id"`
	ApplicationID *string   `db:"application_id" json:"application_id"`
	Status        string    `db:"status" json:"status"`
	CreatedAt     time.Time `db:"created_at" json:"created_at"`
	UpdatedAt     time.Time `db:"updated_at" json:"updated_at"`
}
