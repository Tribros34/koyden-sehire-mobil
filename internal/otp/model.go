package otp

import "time"

type Verification struct {
	ID         string     `db:"id"`
	Phone      string     `db:"phone"`
	Purpose    string     `db:"purpose"`
	Verified   bool       `db:"verified"`
	Attempts   int        `db:"attempts"`
	IPAddress  *string    `db:"ip_address"`
	UserAgent  *string    `db:"user_agent"`
	CreatedAt  time.Time  `db:"created_at"`
	VerifiedAt *time.Time `db:"verified_at"`
}
