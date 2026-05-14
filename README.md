# Köyden Şehre Backend

Mobile-first farmer/producer listing platform API.

## Prerequisites

- Docker & Docker Compose
- Go 1.23+ (for local development)

## Setup

```bash
git clone https://github.com/koydensehire/backend.git
cd backend
cp .env.example .env
# Edit .env with your values
docker compose up -d
```

The API will be available at `http://localhost:8080`.

## Default Admin Credentials

- **Phone:** `05000000000`
- **Password:** `admin123`

## Services

| Service       | URL                        | Credentials                  |
|---------------|----------------------------|------------------------------|
| API           | http://localhost:8080      | —                            |
| MinIO         | http://localhost:9000      | minioadmin / minioadmin123   |
| MinIO Console | http://localhost:9001      | minioadmin / minioadmin123   |
| n8n           | http://localhost:5678      | —                            |
| PostgreSQL    | localhost:5432             | admin / localpass            |
| Redis         | localhost:6379             | —                            |

## Health Check

```bash
curl http://localhost:8080/api/v1/health
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [TESTING.md](TESTING.md) | All curl commands for manual end-to-end testing |
| [docs/API_REFERENCE.md](docs/API_REFERENCE.md) | Full endpoint reference |
| [docs/AUTH_FLOW.md](docs/AUTH_FLOW.md) | OTP + JWT auth flow, invite codes |
| [docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md) | All tables, columns, constraints |
| [docs/ENVIRONMENT.md](docs/ENVIRONMENT.md) | All environment variables + prod checklist |
| [docs/ERROR_FORMAT.md](docs/ERROR_FORMAT.md) | Error codes and HTTP status mapping |
| [docs/UPLOADS_AND_STORAGE.md](docs/UPLOADS_AND_STORAGE.md) | Presigned URL upload flow (R2/S3) |
| [docs/MOBILE_INTEGRATION_GUIDE.md](docs/MOBILE_INTEGRATION_GUIDE.md) | React Native / Flutter integration |
| [docs/NEXTJS_INTEGRATION_GUIDE.md](docs/NEXTJS_INTEGRATION_GUIDE.md) | Next.js 14 App Router integration |
| [docs/openapi.yaml](docs/openapi.yaml) | OpenAPI 3.0 spec |
| [docs/POSTMAN_COLLECTION.json](docs/POSTMAN_COLLECTION.json) | Postman collection with auto-token capture |

---

## API Overview

All routes are prefixed with `/api/v1`.

### Public Routes
- `GET /health` — health check
- `POST /otp/send` — send OTP to phone
- `POST /otp/verify` — verify OTP code
- `POST /auth/login` — login with phone + password
- `GET /categories` — list active categories (with children tree)
- `GET /products` — list products (filterable by city, category, price, etc.)
- `GET /products/:id` — get single product
- `GET /farmers/:id` — get farmer profile
- `GET /farmers/:id/products` — get farmer's products
- `GET /invites/validate?code=KYS-XXXXXX` — validate invite code

### Farmer Application
- `POST /farmer-applications` — submit farmer application (requires OTP verified)
- `POST /uploads/application-video/presigned-url` — get video upload URL

### Farmer (authenticated, role=farmer, status=active)
- `GET /farmer/profile` / `PUT /farmer/profile`
- `GET /farmer/products` / `POST /farmer/products`
- `GET /farmer/products/:id` / `PUT /farmer/products/:id`
- `PATCH /farmer/products/:id/status`
- `GET /farmer/invites`
- `POST /farmer/uploads/product-image`
- `POST /farmer/uploads/profile-image`

### Admin (authenticated, role=admin)
- `GET /admin/dashboard`
- `GET /admin/applications` / `GET /admin/applications/:id`
- `POST /admin/applications/:id/approve`
- `POST /admin/applications/:id/reject`
- `POST /admin/applications/:id/request-video`
- `GET /admin/farmers` / `GET /admin/farmers/:id`
- `POST /admin/farmers/:id/suspend` / `reactivate`
- `PATCH /admin/farmers/:id/founding` / `invite-quota`
- `GET /admin/products` / `GET /admin/products/:id`
- `POST /admin/products/:id/approve` / `reject` / `hide`
- `DELETE /admin/products/:id`
- `GET /admin/categories` / `POST /admin/categories`
- `PUT /admin/categories/:id` / `DELETE /admin/categories/:id`

---

## Invite Code Format

Valid codes: `KYS-{6 uppercase alphanumeric}` (e.g. `KYS-7GHT92`)  
Special code: `KYS-FOUNDER` (50 uses, owned by admin)

---

## Manual Migrations

```bash
migrate -path migrations -database "postgres://admin:localpass@localhost:5432/koydensehire?sslmode=disable" up
```

---

## Development Notes

- In `APP_ENV=development`, OTP codes are logged to stdout (masked phone), debug logs are enabled
- In `APP_ENV=production`, no sensitive data is logged; SMS sent via Netgsm
- Videos are private: served via presigned GET URLs (1h expiry)
- Product/profile images are public via `STORAGE_PUBLIC_URL`
- All `SELECT *` queries scan into fully-matched structs — no silent field loss

See [TESTING.md](TESTING.md) for a complete testing walkthrough.
