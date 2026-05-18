package categories

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

func (h *Handler) List(c *fiber.Ctx) error {
	cats, err := h.svc.ListPublic()
	if err != nil {
		return response.Error(c, err)
	}
	return response.Success(c, cats, "")
}

func (h *Handler) AdminList(c *fiber.Ctx) error {
	cats, err := h.svc.ListAll()
	if err != nil {
		return response.Error(c, err)
	}
	return response.Success(c, cats, "")
}

func (h *Handler) Create(c *fiber.Ctx) error {
	var req CreateCategoryRequest
	if err := c.BodyParser(&req); err != nil {
		return response.BadRequest(c, "Geçersiz istek gövdesi")
	}
	if err := validator.Validate(&req); err != nil {
		return response.BadRequest(c, "Zorunlu alanlar eksik")
	}

	cat, err := h.svc.Create(&req)
	if err != nil {
		return response.Error(c, err)
	}
	return response.Created(c, cat, "Kategori oluşturuldu")
}

func (h *Handler) Update(c *fiber.Ctx) error {
	id := c.Params("id")
	var req UpdateCategoryRequest
	if err := c.BodyParser(&req); err != nil {
		return response.BadRequest(c, "Geçersiz istek gövdesi")
	}
	if err := validator.Validate(&req); err != nil {
		return response.BadRequest(c, "Zorunlu alanlar eksik")
	}

	cat, err := h.svc.Update(id, &req)
	if err != nil {
		return response.Error(c, err)
	}
	return response.Success(c, cat, "Kategori güncellendi")
}

func (h *Handler) Delete(c *fiber.Ctx) error {
	id := c.Params("id")
	if err := h.svc.Delete(id); err != nil {
		return response.Error(c, err)
	}
	return response.Success(c, nil, "Kategori silindi")
}
