package invites

type ValidateRequest struct {
	Code string `query:"code" json:"code"`
}

type ValidateResponse struct {
	Valid     bool   `json:"valid"`
	Code      string `json:"code"`
	Remaining int    `json:"remaining"`
}
