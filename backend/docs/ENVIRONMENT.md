# Environment Variables — Köyden Şehre Backend

Copy `.env.example` to `.env` and fill in values before running.

---

## App

| Variable | Default | Description |
|----------|---------|-------------|
| `APP_ENV` | `development` | `development` or `production`. Controls debug logs, SMS provider |
| `APP_PORT` | `8080` | HTTP listen port |
| `APP_BASE_URL` | `http://localhost:8080` | Used in generated URLs |
| `APP_AUTO_MIGRATE` | `true` | Run DB migrations on startup |
| `APP_CORS_ORIGINS` | `*` | Comma-separated allowed origins |

## Database

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | ✅ | PostgreSQL DSN: `postgres://user:pass@host:5432/db?sslmode=disable` |
| `DATABASE_MAX_CONNECTIONS` | | Default: 10 |
| `DATABASE_MAX_IDLE` | | Default: 5 |

## Redis

| Variable | Required | Description |
|----------|----------|-------------|
| `REDIS_URL` | ✅ | `redis://localhost:6379` |
| `REDIS_PASSWORD` | | Leave empty if no auth |

## JWT

| Variable | Required | Description |
|----------|----------|-------------|
| `JWT_SECRET` | ✅ | Min 32-char random string |
| `JWT_ACCESS_TOKEN_EXPIRY` | | Default: `24h`. Format: `24h`, `1h`, `30m` |

## OTP

| Variable | Default | Description |
|----------|---------|-------------|
| `OTP_EXPIRY_SECONDS` | `300` | OTP validity window (5 min) |
| `OTP_MAX_ATTEMPTS` | `3` | Wrong attempts before invalidation |
| `OTP_RESEND_COOLDOWN_SECONDS` | `60` | Seconds between resend requests |

## SMS (Netgsm)

Only used when `APP_ENV=production`. In development, OTP is logged to stdout.

| Variable | Required | Description |
|----------|----------|-------------|
| `SMS_USERNAME` | prod only | Netgsm account username |
| `SMS_PASSWORD` | prod only | Netgsm account password |
| `SMS_HEADER` | prod only | Approved SMS sender name |

## Storage (Cloudflare R2 / S3-compatible)

| Variable | Required | Description |
|----------|----------|-------------|
| `STORAGE_ENDPOINT` | ✅ | R2/S3 endpoint URL |
| `STORAGE_BUCKET` | ✅ | Bucket name |
| `STORAGE_ACCESS_KEY` | ✅ | Access key ID |
| `STORAGE_SECRET_KEY` | ✅ | Secret access key |
| `STORAGE_PUBLIC_URL` | ✅ | Public CDN URL for serving images |

## n8n Webhooks

| Variable | Required | Description |
|----------|----------|-------------|
| `N8N_WEBHOOK_URL` | | n8n webhook base URL |
| `N8N_WEBHOOK_SECRET` | | Shared secret for webhook auth |

---

## Docker Compose

In `docker-compose.yml`, variables are read from `.env` automatically.  
The `api` service passes them as environment variables to the container.

## Production Checklist

- [ ] `APP_ENV=production`
- [ ] Strong `JWT_SECRET` (32+ chars)
- [ ] `DATABASE_URL` points to prod DB with SSL
- [ ] SMS credentials set
- [ ] `APP_CORS_ORIGINS` restricted to actual frontend domain
- [ ] Storage credentials set
