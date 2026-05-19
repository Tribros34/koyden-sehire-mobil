package invites

type ValidateRequest struct {
	Code string `query:"code" json:"code"`
}

type ValidateResponse struct {
	Valid     bool   `json:"valid"`
	Code      string `json:"code"`
	MaxUses   int    `json:"max_uses"`
	UsedCount int    `json:"used_count"`
	Remaining int    `json:"remaining"`
}
