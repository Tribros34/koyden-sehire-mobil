package uploads

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"path/filepath"
	"strings"
	"time"

	apperrors "github.com/koydensehire/backend/pkg/errors"
	"github.com/koydensehire/backend/pkg/storage"
)

type Service struct {
	storage storage.Provider
}

func NewService(stor storage.Provider) *Service {
	return &Service{storage: stor}
}

var allowedImageTypes = map[string]bool{
	"image/jpeg": true,
	"image/png":  true,
	"image/webp": true,
}

func (s *Service) UploadProductImage(farmerID string, file io.Reader, filename string, size int64) (*UploadImageResponse, error) {
	if size > 5*1024*1024 {
		return nil, apperrors.New("FILE_TOO_LARGE", "Resim 5MB'dan büyük olamaz", 400)
	}

	buf := make([]byte, 512)
	n, err := io.ReadFull(file, buf)
	if err != nil && err != io.ErrUnexpectedEOF && err != io.EOF {
		return nil, apperrors.ErrInternal
	}
	buf = buf[:n]

	contentType := http.DetectContentType(buf)
	if !allowedImageTypes[contentType] {
		return nil, apperrors.New("INVALID_FILE_TYPE", "Sadece JPEG, PNG veya WebP yükleyebilirsiniz", 400)
	}

	combined := io.MultiReader(bytes.NewReader(buf), file)
	key := fmt.Sprintf("product-images/%s/%d_%s", farmerID, time.Now().Unix(), sanitizeFilename(filename))

	url, err := s.storage.Upload(context.Background(), key, combined, contentType, size)
	if err != nil {
		return nil, apperrors.ErrInternal
	}

	return &UploadImageResponse{URL: url}, nil
}

func (s *Service) UploadProfileImage(farmerID string, file io.Reader, filename string, size int64) (*UploadImageResponse, error) {
	if size > 2*1024*1024 {
		return nil, apperrors.New("FILE_TOO_LARGE", "Profil resmi 2MB'dan büyük olamaz", 400)
	}

	buf := make([]byte, 512)
	n, err := io.ReadFull(file, buf)
	if err != nil && err != io.ErrUnexpectedEOF && err != io.EOF {
		return nil, apperrors.ErrInternal
	}
	buf = buf[:n]

	contentType := http.DetectContentType(buf)
	if !allowedImageTypes[contentType] {
		return nil, apperrors.New("INVALID_FILE_TYPE", "Sadece JPEG, PNG veya WebP yükleyebilirsiniz", 400)
	}

	combined := io.MultiReader(bytes.NewReader(buf), file)
	key := fmt.Sprintf("profile-images/%s/%d_%s", farmerID, time.Now().Unix(), sanitizeFilename(filename))

	url, err := s.storage.Upload(context.Background(), key, combined, contentType, size)
	if err != nil {
		return nil, apperrors.ErrInternal
	}

	return &UploadImageResponse{URL: url}, nil
}

func sanitizeFilename(name string) string {
	ext := filepath.Ext(name)
	base := strings.TrimSuffix(name, ext)
	safe := strings.Map(func(r rune) rune {
		if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') || r == '-' || r == '_' {
			return r
		}
		return '_'
	}, base)
	return safe + ext
}
