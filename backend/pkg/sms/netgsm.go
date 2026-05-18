package sms

import (
	"fmt"
	"io"
	"net/http"
	"strings"
)

type NetgsmProvider struct {
	username string
	password string
	header   string
}

func NewNetgsmProvider(username, password, header string) *NetgsmProvider {
	return &NetgsmProvider{
		username: username,
		password: password,
		header:   header,
	}
}

func (n *NetgsmProvider) Send(phone, message string) error {
	formatted := formatPhone(phone)

	body := fmt.Sprintf(`<?xml version="1.0" encoding="UTF-8"?>
<mainbody>
  <header>
    <company dil="TR">Netgsm</company>
    <usercode>%s</usercode>
    <password>%s</password>
    <type>1:n</type>
    <msgheader>%s</msgheader>
  </header>
  <body>
    <msg><![CDATA[%s]]></msg>
    <no>%s</no>
  </body>
</mainbody>`, n.username, n.password, n.header, message, formatted)

	resp, err := http.Post(
		"https://api.netgsm.com.tr/sms/send/xml",
		"text/xml",
		strings.NewReader(body),
	)
	if err != nil {
		return fmt.Errorf("netgsm request failed: %w", err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	result := strings.TrimSpace(string(respBody))

	if !strings.HasPrefix(result, "00") {
		return fmt.Errorf("netgsm error code: %s", result)
	}
	return nil
}

func formatPhone(phone string) string {
	phone = strings.TrimSpace(phone)
	if strings.HasPrefix(phone, "0") {
		phone = "90" + phone[1:]
	}
	return phone
}
