package users

import apperrors "github.com/koydensehire/backend/pkg/errors"

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetProfile(userID string) (*User, *FarmerProfile, error) {
	user, err := s.repo.GetByID(userID)
	if err != nil {
		return nil, nil, err
	}
	profile, err := s.repo.GetFarmerProfile(userID)
	if err != nil {
		return nil, nil, apperrors.ErrNotFound
	}
	return user, profile, nil
}

func (s *Service) UpdateProfile(userID string, req *UpdateProfileRequest) error {
	return s.repo.UpdateFarmerProfile(userID, req)
}
