package admin

import (
	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) GetDashboardStats() (*DashboardStats, error) {
	var stats DashboardStats

	r.db.Get(&stats.TotalFarmers, "SELECT COUNT(*) FROM users WHERE role = 'farmer'")
	r.db.Get(&stats.PendingApplications, "SELECT COUNT(*) FROM farmer_applications WHERE status IN ('pending', 'needs_video')")
	r.db.Get(&stats.PendingProducts, "SELECT COUNT(*) FROM products WHERE status = 'pending'")
	r.db.Get(&stats.ActiveProducts, "SELECT COUNT(*) FROM products WHERE status = 'active'")
	r.db.Get(&stats.TotalProducts, "SELECT COUNT(*) FROM products")

	return &stats, nil
}
