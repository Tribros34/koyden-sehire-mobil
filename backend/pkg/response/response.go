package response

import (
	"github.com/gofiber/fiber/v2"
	apperrors "github.com/koydensehire/backend/pkg/errors"
)

type successResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Message string      `json:"message,omitempty"`
}

type errorDetail struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

type errorResponse struct {
	Success bool        `json:"success"`
	Error   errorDetail `json:"error"`
}

type Pagination struct {
	Page       int `json:"page"`
	Limit      int `json:"limit"`
	Total      int `json:"total"`
	TotalPages int `json:"total_pages"`
}

type paginatedResponse struct {
	Success    bool        `json:"success"`
	Data       interface{} `json:"data"`
	Pagination Pagination  `json:"pagination"`
}

func Success(c *fiber.Ctx, data interface{}, message string) error {
	return c.Status(200).JSON(successResponse{
		Success: true,
		Data:    data,
		Message: message,
	})
}

func Created(c *fiber.Ctx, data interface{}, message string) error {
	return c.Status(201).JSON(successResponse{
		Success: true,
		Data:    data,
		Message: message,
	})
}

func Paginated(c *fiber.Ctx, data interface{}, p Pagination) error {
	return c.Status(200).JSON(paginatedResponse{
		Success:    true,
		Data:       data,
		Pagination: p,
	})
}

func Error(c *fiber.Ctx, err error) error {
	var appErr *apperrors.AppError
	if e, ok := err.(*apperrors.AppError); ok {
		appErr = e
	} else {
		appErr = apperrors.ErrInternal
	}
	return c.Status(appErr.StatusCode).JSON(errorResponse{
		Success: false,
		Error: errorDetail{
			Code:    appErr.Code,
			Message: appErr.Message,
		},
	})
}

func BadRequest(c *fiber.Ctx, message string) error {
	return c.Status(400).JSON(errorResponse{
		Success: false,
		Error:   errorDetail{Code: "BAD_REQUEST", Message: message},
	})
}

func NotFound(c *fiber.Ctx, message string) error {
	return c.Status(404).JSON(errorResponse{
		Success: false,
		Error:   errorDetail{Code: "NOT_FOUND", Message: message},
	})
}

func Unauthorized(c *fiber.Ctx, message string) error {
	return c.Status(401).JSON(errorResponse{
		Success: false,
		Error:   errorDetail{Code: "UNAUTHORIZED", Message: message},
	})
}

func Forbidden(c *fiber.Ctx, message string) error {
	return c.Status(403).JSON(errorResponse{
		Success: false,
		Error:   errorDetail{Code: "FORBIDDEN", Message: message},
	})
}

func Conflict(c *fiber.Ctx, message string) error {
	return c.Status(409).JSON(errorResponse{
		Success: false,
		Error:   errorDetail{Code: "CONFLICT", Message: message},
	})
}

func TooManyRequests(c *fiber.Ctx, message string) error {
	return c.Status(429).JSON(errorResponse{
		Success: false,
		Error:   errorDetail{Code: "TOO_MANY_REQUESTS", Message: message},
	})
}
