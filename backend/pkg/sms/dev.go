package sms

import "log"

type DevProvider struct{}

func (d *DevProvider) Send(phone, message string) error {
	log.Printf("[DEV SMS] to %s: %s", maskPhone(phone), message)
	return nil
}

func maskPhone(phone string) string {
	if len(phone) < 7 {
		return "***"
	}
	return phone[:3] + "***" + phone[7:]
}
