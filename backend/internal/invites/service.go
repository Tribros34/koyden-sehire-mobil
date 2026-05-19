package invites

import (
	"strings"

	apperrors "github.com/koydensehire/backend/pkg/errors"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Validate(code string) (*ValidateResponse, error) {
	code = strings.ToUpper(strings.TrimSpace(code))
	if !isValidCodeFormat(code) {
		return nil, apperrors.New("INVALID_CODE_FORMAT", "Geçersiz davet kodu formatı", 400)
	}

	ic, err := s.repo.FindByCode(code)
	if err != nil {
		return nil, apperrors.New("INVALID_CODE", "Davet kodu bulunamadı", 404)
	}

	if !s.repo.IsCodeValid(ic) {
		return nil, apperrors.New("CODE_EXPIRED", "Davet kodu geçersiz veya dolmuş", 400)
	}

	return &ValidateResponse{
		Valid:     true,
		Code:      ic.Code,
		MaxUses:   ic.MaxUses,
		UsedCount: ic.UsedCount,
		Remaining: ic.MaxUses - ic.UsedCount,
	}, nil
}

func (s *Service) GetFarmerInvites(farmerID string) ([]InviteCode, error) {
	return s.repo.FindByOwner(farmerID)
}

func isValidCodeFormat(code string) bool {
	if code == "KYS-FOUNDER" {
		return true
	}
	if len(code) != 10 {
		return false
	}
	if !strings.HasPrefix(code, "KYS-") {
		return false
	}
	suffix := code[4:]
	for _, c := range suffix {
		if !((c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')) {
			return false
		}
	}
	return true
}
