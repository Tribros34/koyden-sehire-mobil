package products

import (
	"fmt"
	"strings"

	"github.com/jmoiron/sqlx"
	apperrors "github.com/koydensehire/backend/pkg/errors"
)

type Service struct {
	repo      *Repository
	db        *sqlx.DB
	publicURL string
}

func NewService(repo *Repository, db *sqlx.DB, publicURL string) *Service {
	return &Service{repo: repo, db: db, publicURL: publicURL}
}

func (s *Service) ListPublic(f *ProductFilter) ([]PublicProduct, int, error) {
	return s.repo.ListPublic(f)
}

func (s *Service) GetPublicByID(id string) (*PublicProduct, error) {
	return s.repo.GetPublicByID(id)
}

func (s *Service) GetByID(id string) (*Product, error) {
	return s.repo.GetByID(id)
}

func (s *Service) GetByIDAndFarmer(id, farmerID string) (*Product, error) {
	return s.repo.GetByIDAndFarmer(id, farmerID)
}

func (s *Service) ListByFarmer(farmerID string) ([]Product, error) {
	return s.repo.ListByFarmer(farmerID)
}

func (s *Service) ListByFarmerPublic(farmerID string) ([]PublicProduct, error) {
	return s.repo.ListByFarmerPublic(farmerID)
}

func (s *Service) Create(farmerID string, req *CreateProductRequest) (*Product, error) {
	if err := s.validateImageURLs(req.ImageURLs); err != nil {
		return nil, err
	}

	var cat struct {
		ParentID *string `db:"parent_id"`
		IsActive bool    `db:"is_active"`
	}
	if err := s.db.Get(&cat, "SELECT parent_id, is_active FROM categories WHERE id = $1", req.CategoryID); err != nil {
		return nil, apperrors.New("INVALID_CATEGORY", "Kategori bulunamadı", 400)
	}
	if !cat.IsActive {
		return nil, apperrors.New("INVALID_CATEGORY", "Bu kategori aktif değil", 400)
	}
	if cat.ParentID == nil {
		return nil, apperrors.New("INVALID_CATEGORY", "Ana kategori seçilemez, alt kategori seçin", 400)
	}

	return s.repo.Create(farmerID, req)
}

func (s *Service) Update(id, farmerID string, req *UpdateProductRequest) (*Product, error) {
	if err := s.validateImageURLs(req.ImageURLs); err != nil {
		return nil, err
	}

	existing, err := s.repo.GetByIDAndFarmer(id, farmerID)
	if err != nil {
		return nil, apperrors.ErrNotFound
	}
	_ = existing

	return s.repo.Update(id, farmerID, req)
}

func (s *Service) UpdateStatus(id, farmerID, status string) error {
	allowed := map[string]bool{"passive": true, "pending": true}
	if !allowed[status] {
		return apperrors.New("INVALID_STATUS", "Geçersiz durum değeri", 400)
	}

	existing, err := s.repo.GetByIDAndFarmer(id, farmerID)
	if err != nil {
		return apperrors.ErrNotFound
	}

	if status == "pending" && existing.Status != "passive" {
		return apperrors.New("INVALID_STATUS_TRANSITION", "Sadece pasif ürünler yeniden aktif edilebilir", 400)
	}
	if status == "passive" && existing.Status != "active" {
		return apperrors.New("INVALID_STATUS_TRANSITION", "Sadece aktif ürünler pasif yapılabilir", 400)
	}

	return s.repo.UpdateStatus(id, farmerID, status)
}

func (s *Service) AdminApprove(id string) error {
	p, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	if p.Status != "pending" {
		return apperrors.New("INVALID_STATUS", "Sadece bekleyen ürünler onaylanabilir", 400)
	}
	return s.repo.AdminApprove(id)
}

func (s *Service) AdminReject(id, note string) error {
	_, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	_, err = s.db.Exec(`
		UPDATE products SET status = 'rejected', admin_note = $1, updated_at = NOW() WHERE id = $2
	`, note, id)
	return err
}

func (s *Service) AdminHide(id string) error {
	_, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	return s.repo.AdminHide(id)
}

func (s *Service) AdminDelete(id string) error {
	_, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	return s.repo.AdminDelete(id)
}

func (s *Service) ListAll(page, limit int) ([]Product, int, error) {
	return s.repo.ListAll(page, limit)
}

func (s *Service) validateImageURLs(urls []string) error {
	if s.publicURL == "" {
		return nil
	}
	baseURL := strings.TrimRight(s.publicURL, "/")
	for _, url := range urls {
		if !strings.HasPrefix(url, baseURL) {
			return apperrors.New("INVALID_IMAGE_URL", fmt.Sprintf("Geçersiz resim URL'i: %s", url), 400)
		}
	}
	return nil
}
