package invites

import (
	"github.com/gofiber/fiber/v2"
	"github.com/koydensehire/backend/internal/middleware"
	"github.com/koydensehire/backend/pkg/response"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) Validate(c *fiber.Ctx) error {
	code := c.Query("code")
	if code == "" {
		return response.BadRequest(c, "Davet kodu zorunludur")
	}

	resp, err := h.svc.Validate(code)
	if err != nil {
		return response.Error(c, err)
	}
	return response.Success(c, resp, "")
}

func (h *Handler) FarmerInvites(c *fiber.Ctx) error {
	farmerID := c.Locals(middleware.UserIDKey).(string)

	codes, err := h.svc.GetFarmerInvites(farmerID)
	if err != nil {
		return response.Error(c, err)
	}
	return response.Success(c, codes, "")
}
