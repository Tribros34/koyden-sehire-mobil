package admin

type ApproveApplicationRequest struct {
	IsFoundingFarmer bool `json:"is_founding_farmer"`
	InviteQuota      *int `json:"invite_quota"`
}

type RejectApplicationRequest struct {
	AdminNote       string `json:"admin_note"`
	RejectionReason string `json:"rejection_reason" validate:"required"`
}

type DashboardStats struct {
	TotalFarmers        int `json:"total_farmers"`
	PendingApplications int `json:"pending_applications"`
	PendingProducts     int `json:"pending_products"`
	ActiveProducts      int `json:"active_products"`
	TotalProducts       int `json:"total_products"`
}
