package storage

import (
	"context"
	"fmt"
	"io"
	"time"
)

type NoopProvider struct{}

func (n *NoopProvider) Upload(ctx context.Context, key string, file io.Reader, contentType string, size int64) (string, error) {
	return fmt.Sprintf("/uploads/%s", key), nil
}

func (n *NoopProvider) GeneratePresignedPutURL(ctx context.Context, key string, ttl time.Duration) (string, error) {
	return fmt.Sprintf("http://localhost:9000/%s", key), nil
}

func (n *NoopProvider) GeneratePresignedGetURL(ctx context.Context, key string, ttl time.Duration) (string, error) {
	return fmt.Sprintf("http://localhost:9000/%s", key), nil
}

func (n *NoopProvider) Delete(ctx context.Context, key string) error {
	return nil
}
