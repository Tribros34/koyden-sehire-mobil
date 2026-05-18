package storage

import (
	"context"
	"io"
	"time"
)

type Provider interface {
	Upload(ctx context.Context, key string, file io.Reader, contentType string, size int64) (string, error)
	GeneratePresignedPutURL(ctx context.Context, key string, ttl time.Duration) (string, error)
	GeneratePresignedGetURL(ctx context.Context, key string, ttl time.Duration) (string, error)
	Delete(ctx context.Context, key string) error
}
