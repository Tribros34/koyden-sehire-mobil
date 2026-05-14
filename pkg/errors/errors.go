package errors

import "errors"

type AppError struct {
	Code       string
	Message    string
	StatusCode int
}

func (e *AppError) Error() string {
	return e.Message
}

func New(code, message string, statusCode int) *AppError {
	return &AppError{Code: code, Message: message, StatusCode: statusCode}
}

var (
	ErrNotFound     = New("NOT_FOUND", "Kayıt bulunamadı", 404)
	ErrUnauthorized = New("UNAUTHORIZED", "Kimlik doğrulama gerekli", 401)
	ErrForbidden    = New("FORBIDDEN", "Bu işlem için yetkiniz yok", 403)
	ErrBadRequest   = New("BAD_REQUEST", "Geçersiz istek", 400)
	ErrConflict     = New("CONFLICT", "Bu kayıt zaten mevcut", 409)
	ErrInternal     = New("INTERNAL_ERROR", "Sunucu hatası", 500)
)

func IsNotFound(err error) bool {
	var appErr *AppError
	if errors.As(err, &appErr) {
		return appErr.StatusCode == 404
	}
	return false
}

func IsConflict(err error) bool {
	var appErr *AppError
	if errors.As(err, &appErr) {
		return appErr.StatusCode == 409
	}
	return false
}
