package middleware

import (
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/jmoiron/sqlx"
	"github.com/koydensehire/backend/pkg/response"
)

type contextKey string

const (
	UserIDKey     = "user_id"
	UserRoleKey   = "user_role"
	UserStatusKey = "user_status"
)

func RequireAuth(db *sqlx.DB, jwtSecret string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		header := c.Get("Authorization")
		if header == "" || !strings.HasPrefix(header, "Bearer ") {
			return response.Unauthorized(c, "Kimlik doğrulama gerekli")
		}

		tokenStr := strings.TrimPrefix(header, "Bearer ")

		token, err := jwt.Parse(
			tokenStr,
			func(t *jwt.Token) (interface{}, error) {
				if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
					return nil, fiber.NewError(401, "Geçersiz token imzalama metodu")
				}
				return []byte(jwtSecret), nil
			},
			jwt.WithValidMethods([]string{"HS256"}),
			jwt.WithExpirationRequired(),
		)
		if err != nil || !token.Valid {
			return response.Unauthorized(c, "Geçersiz veya süresi dolmuş token")
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			return response.Unauthorized(c, "Geçersiz token")
		}

		// Defense in depth: explicitly verify exp claim is in the future,
		// in case the library default ever changes.
		if exp, ok := claims["exp"].(float64); !ok || int64(exp) <= 0 {
			return response.Unauthorized(c, "Geçersiz token")
		}

		userID, ok := claims["user_id"].(string)
		if !ok || userID == "" {
			return response.Unauthorized(c, "Geçersiz token")
		}

		var user struct {
			ID     string `db:"id"`
			Role   string `db:"role"`
			Status string `db:"status"`
		}
		err = db.Get(&user, "SELECT id, role, status FROM users WHERE id = $1", userID)
		if err != nil {
			return response.Unauthorized(c, "Kullanıcı bulunamadı")
		}

		c.Locals(UserIDKey, user.ID)
		c.Locals(UserRoleKey, user.Role)
		c.Locals(UserStatusKey, user.Status)

		return c.Next()
	}
}

func RequireRole(role string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userRole, ok := c.Locals(UserRoleKey).(string)
		if !ok || userRole != role {
			return response.Forbidden(c, "Bu işlem için yetkiniz yok")
		}
		return c.Next()
	}
}

func RequireActiveUser() fiber.Handler {
	return func(c *fiber.Ctx) error {
		status, ok := c.Locals(UserStatusKey).(string)
		if !ok || status != "active" {
			return response.Forbidden(c, "Hesabınız askıya alınmıştır")
		}
		return c.Next()
	}
}
