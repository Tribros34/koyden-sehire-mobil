package otp

type SendRequest struct {
	Phone string `json:"phone" validate:"required"`
}

type SendResponse struct {
	Message   string  `json:"message"`
	ExpiresIn int     `json:"expires_in"`
	DevCode   *string `json:"dev_code,omitempty"`
}

type VerifyRequest struct {
	Phone string `json:"phone" validate:"required"`
	Code  string `json:"code" validate:"required"`
}

type VerifyResponse struct {
	Verified bool `json:"verified"`
}
