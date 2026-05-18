package middleware

import (
	"context"
	"fmt"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/koydensehire/backend/pkg/response"
	"github.com/redis/go-redis/v9"
)

type RateLimitConfig struct {
	KeyFunc func(c *fiber.Ctx) string
	Max     int
	Window  time.Duration
}

func RateLimit(rdb *redis.Client, cfg RateLimitConfig) fiber.Handler {
	return func(c *fiber.Ctx) error {
		key := "rl:" + cfg.KeyFunc(c)
		ctx := context.Background()

		count, err := rdb.Incr(ctx, key).Result()
		if err != nil {
			return c.Next()
		}

		if count == 1 {
			rdb.Expire(ctx, key, cfg.Window)
		}

		if count > int64(cfg.Max) {
			return response.TooManyRequests(c, "Çok fazla istek gönderdiniz, lütfen bekleyin")
		}

		return c.Next()
	}
}

func OTPSendRateLimit(rdb *redis.Client) fiber.Handler {
	return RateLimit(rdb, RateLimitConfig{
		KeyFunc: func(c *fiber.Ctx) string {
			var body struct {
				Phone string `json:"phone"`
			}
			c.BodyParser(&body)
			return fmt.Sprintf("otp:%s", body.Phone)
		},
		Max:    3,
		Window: time.Hour,
	})
}

func LoginRateLimit(rdb *redis.Client) fiber.Handler {
	return RateLimit(rdb, RateLimitConfig{
		KeyFunc: func(c *fiber.Ctx) string {
			return fmt.Sprintf("login:%s", c.IP())
		},
		Max:    10,
		Window: 15 * time.Minute,
	})
}

func InviteValidateRateLimit(rdb *redis.Client) fiber.Handler {
	return RateLimit(rdb, RateLimitConfig{
		KeyFunc: func(c *fiber.Ctx) string {
			return fmt.Sprintf("invite:%s", c.IP())
		},
		Max:    20,
		Window: time.Hour,
	})
}

func VideoPresignRateLimit(rdb *redis.Client) fiber.Handler {
	return func(c *fiber.Ctx) error {
		ctx := context.Background()

		var body struct {
			Phone string `json:"phone"`
		}
		c.BodyParser(&body)

		phoneKey := fmt.Sprintf("rl:video_presign:%s", body.Phone)
		ipKey := fmt.Sprintf("rl:video_presign_ip:%s", c.IP())

		phoneCount, err := rdb.Incr(ctx, phoneKey).Result()
		if err == nil && phoneCount == 1 {
			rdb.Expire(ctx, phoneKey, time.Hour)
		}

		ipCount, err := rdb.Incr(ctx, ipKey).Result()
		if err == nil && ipCount == 1 {
			rdb.Expire(ctx, ipKey, time.Hour)
		}

		if phoneCount > 5 || ipCount > 10 {
			return response.TooManyRequests(c, "Çok fazla istek gönderdiniz, lütfen bekleyin")
		}

		return c.Next()
	}
}
