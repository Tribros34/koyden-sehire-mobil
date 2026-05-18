package uploads

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

func (h *Handler) UploadProductImage(c *fiber.Ctx) error {
	farmerID := c.Locals(middleware.UserIDKey).(string)

	file, err := c.FormFile("file")
	if err != nil {
		return response.BadRequest(c, "Dosya bulunamadı")
	}

	f, err := file.Open()
	if err != nil {
		return response.BadRequest(c, "Dosya açılamadı")
	}
	defer f.Close()

	resp, err := h.svc.UploadProductImage(farmerID, f, file.Filename, file.Size)
	if err != nil {
		return response.Error(c, err)
	}

	return response.Success(c, resp, "Resim yüklendi")
}

func (h *Handler) UploadProfileImage(c *fiber.Ctx) error {
	farmerID := c.Locals(middleware.UserIDKey).(string)

	file, err := c.FormFile("file")
	if err != nil {
		return response.BadRequest(c, "Dosya bulunamadı")
	}

	f, err := file.Open()
	if err != nil {
		return response.BadRequest(c, "Dosya açılamadı")
	}
	defer f.Close()

	resp, err := h.svc.UploadProfileImage(farmerID, f, file.Filename, file.Size)
	if err != nil {
		return response.Error(c, err)
	}

	return response.Success(c, resp, "Profil resmi yüklendi")
}
