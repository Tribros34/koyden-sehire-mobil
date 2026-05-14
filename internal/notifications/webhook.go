package notifications

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

type WebhookService struct {
	webhookURL    string
	webhookSecret string
}

func NewWebhookService(url, secret string) *WebhookService {
	return &WebhookService{webhookURL: url, webhookSecret: secret}
}

func (w *WebhookService) Fire(payload interface{}) {
	if w.webhookURL == "" {
		return
	}
	go func() {
		if err := w.send(payload); err != nil {
			log.Printf("webhook error: %v", err)
		}
	}()
}

func (w *WebhookService) send(payload interface{}) error {
	data, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("marshaling webhook payload: %w", err)
	}

	req, err := http.NewRequest("POST", w.webhookURL, bytes.NewReader(data))
	if err != nil {
		return fmt.Errorf("creating webhook request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Webhook-Secret", w.webhookSecret)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("sending webhook: %w", err)
	}
	defer resp.Body.Close()

	return nil
}

type NewApplicationEvent struct {
	Event             string    `json:"event"`
	ApplicationID     string    `json:"application_id"`
	ApplicantName     string    `json:"applicant_name"`
	Phone             string    `json:"phone"`
	City              string    `json:"city"`
	District          string    `json:"district"`
	ProductCategories []string  `json:"product_categories"`
	HasVideo          bool      `json:"has_video"`
	InviterName       string    `json:"inviter_name"`
	AppliedAt         time.Time `json:"applied_at"`
}

type ApplicationApprovedEvent struct {
	Event         string    `json:"event"`
	ApplicationID string    `json:"application_id"`
	FarmerName    string    `json:"farmer_name"`
	Phone         string    `json:"phone"`
	ApprovedAt    time.Time `json:"approved_at"`
}

type ApplicationRejectedEvent struct {
	Event           string    `json:"event"`
	ApplicationID   string    `json:"application_id"`
	ApplicantName   string    `json:"applicant_name"`
	Phone           string    `json:"phone"`
	RejectionReason string    `json:"rejection_reason"`
	RejectedAt      time.Time `json:"rejected_at"`
}
