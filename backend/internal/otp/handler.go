package otp

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

func (h *Handler) Send(c *fiber.Ctx) error {
	var req SendRequest
	if err := c.BodyParser(&req); err != nil {
		return response.BadRequest(c, "Geçersiz istek gövdesi")
	}
	if err := validator.Validate(&req); err != nil {
		return response.BadRequest(c, "Telefon numarası zorunludur")
	}

	resp, err := h.svc.Send(req.Phone, c.IP(), c.Get("User-Agent"))
	if err != nil {
		return response.Error(c, err)
	}

	return response.Success(c, resp, resp.Message)
}

func (h *Handler) Verify(c *fiber.Ctx) error {
	var req VerifyRequest
	if err := c.BodyParser(&req); err != nil {
		return response.BadRequest(c, "Geçersiz istek gövdesi")
	}
	if err := validator.Validate(&req); err != nil {
		return response.BadRequest(c, "Telefon ve kod zorunludur")
	}

	resp, err := h.svc.Verify(req.Phone, req.Code)
	if err != nil {
		return response.Error(c, err)
	}

	return response.Success(c, resp, "Telefon doğrulandı")
}
