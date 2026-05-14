package sms

type Provider interface {
	Send(phone, message string) error
}
