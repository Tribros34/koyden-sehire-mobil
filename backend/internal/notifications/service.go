package notifications

import "time"

type Service struct {
	webhook *WebhookService
}

func NewService(webhook *WebhookService) *Service {
	return &Service{webhook: webhook}
}

func (s *Service) NewApplication(appID, applicantName, phone, city, district string, categories []string, hasVideo bool, inviterName string) {
	s.webhook.Fire(NewApplicationEvent{
		Event:             "new_application",
		ApplicationID:     appID,
		ApplicantName:     applicantName,
		Phone:             phone,
		City:              city,
		District:          district,
		ProductCategories: categories,
		HasVideo:          hasVideo,
		InviterName:       inviterName,
		AppliedAt:         time.Now(),
	})
}

func (s *Service) ApplicationApproved(appID, farmerName, phone string) {
	s.webhook.Fire(ApplicationApprovedEvent{
		Event:         "application_approved",
		ApplicationID: appID,
		FarmerName:    farmerName,
		Phone:         phone,
		ApprovedAt:    time.Now(),
	})
}

func (s *Service) ApplicationRejected(appID, applicantName, phone, reason string) {
	s.webhook.Fire(ApplicationRejectedEvent{
		Event:           "application_rejected",
		ApplicationID:   appID,
		ApplicantName:   applicantName,
		Phone:           phone,
		RejectionReason: reason,
		RejectedAt:      time.Now(),
	})
}
