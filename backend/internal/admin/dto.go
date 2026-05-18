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
	ActiveFarmers       int `json:"active_farmers"`
	SuspendedFarmers    int `json:"suspended_farmers"`
	PendingApplications int `json:"pending_applications"`
	TodayApplications   int `json:"today_applications"`
	PendingProducts     int `json:"pending_products"`
	ActiveProducts      int `json:"active_products"`
	TotalProducts       int `json:"total_products"`
}

type ChartPoint struct {
	Name  string  `json:"name"`
	Value float64 `json:"value"`
}

type DashboardResponse struct {
	Stats              DashboardStats `json:"stats"`
	ApplicationsByDay  []ChartPoint   `json:"applications_by_day"`
	ProductsByCategory []ChartPoint   `json:"products_by_category"`
	ProducersByCity    []ChartPoint   `json:"producers_by_city"`
}

type CityDensityPoint struct {
	City        string `json:"city"`
	FarmerCount int    `json:"farmer_count"`
}

type InviteNetworkNode struct {
	ID          string              `json:"id"`
	Name        string              `json:"name"`
	InviteCode  string              `json:"invite_code,omitempty"`
	UsedCount   int                 `json:"used_count"`
	MaxUses     int                 `json:"max_uses"`
	Children    []InviteNetworkNode `json:"children"`
}
