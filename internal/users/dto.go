package users

type UpdateProfileRequest struct {
	DisplayName     string  `json:"display_name" validate:"required"`
	ProducerType    string  `json:"producer_type" validate:"required"`
	City            string  `json:"city" validate:"required"`
	District        string  `json:"district" validate:"required"`
	Village         string  `json:"village" validate:"required"`
	Bio             string  `json:"bio" validate:"required"`
	PublicPhone     string  `json:"public_phone" validate:"required"`
	ShowPhone       bool    `json:"show_phone"`
	ProfileImageURL *string `json:"profile_image_url"`
}
