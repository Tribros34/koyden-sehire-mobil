package auth

import (
	"github.com/gofiber/fiber/v2"
	"github.com/koydensehire/backend/pkg/response"
	"github.com/koydensehire/backend/pkg/validator"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) Login(c *fiber.Ctx) error {
	var req LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return response.BadRequest(c, "Geçersiz istek gövdesi")
	}
	if err := validator.Validate(&req); err != nil {
		return response.BadRequest(c, "Telefon ve şifre zorunludur")
	}

	resp, err := h.svc.Login(&req)
	if err != nil {
		return response.Error(c, err)
	}

	return response.Success(c, resp, "Giriş başarılı")
}

func (h *Handler) Refresh(c *fiber.Ctx) error {
	var req RefreshRequest
	if err := c.BodyParser(&req); err != nil {
		return response.BadRequest(c, "Geçersiz istek gövdesi")
	}
	if err := validator.Validate(&req); err != nil {
		return response.BadRequest(c, "refresh_token zorunludur")
	}

	resp, err := h.svc.Refresh(&req)
	if err != nil {
		return response.Error(c, err)
	}

	return response.Success(c, resp, "Token yenilendi")
}

func (h *Handler) RegisterCustomer(c *fiber.Ctx) error {
	var req RegisterCustomerRequest
	if err := c.BodyParser(&req); err != nil {
		return response.BadRequest(c, "Geçersiz istek gövdesi")
	}
	if err := validator.Validate(&req); err != nil {
		return response.BadRequest(c, "Lütfen tüm alanları doğru doldurun")
	}

	resp, err := h.svc.RegisterCustomer(&req)
	if err != nil {
		return response.Error(c, err)
	}

	return response.Success(c, resp, "Kayıt başarılı")
}
