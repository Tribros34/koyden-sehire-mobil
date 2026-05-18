# API Reference — Köyden Şehre Backend

Base URL: `https://api.koydensehire.com/api/v1`  
Development: `http://localhost:8080/api/v1`

All responses follow the format:
```json
{"success": true, "data": {}, "message": ""}
{"success": false, "error": {"code": "ERROR_CODE", "message": "Human-readable message"}}
```

---

## Public Endpoints (No Auth)

### Health
| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Service health check |

### Auth
| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/login` | Login with phone + password → JWT |

**Login body:**
```json
{"phone": "05XXXXXXXXX", "password": "..."}
```

### OTP
| Method | Path | Rate Limit |
|--------|------|-----------|
| POST | `/otp/send` | 1 per cooldown window |
| POST | `/otp/verify` | Max 3 attempts |

**Send body:** `{"phone": "05XXXXXXXXX"}`  
**Verify body:** `{"phone": "05XXXXXXXXX", "code": "123456"}`

### Categories
| Method | Path | Description |
|--------|------|-------------|
| GET | `/categories` | Tree with children |

### Products (Public)
| Method | Path | Description |
|--------|------|-------------|
| GET | `/products` | Paginated active products |
| GET | `/products/:id` | Single product with farmer + category |
| GET | `/farmers/:id` | Public farmer profile |
| GET | `/farmers/:id/products` | Farmer's active products |

**Product filters (query params):**
- `search`, `category_id`, `city`, `district`, `village`
- `min_price`, `max_price`, `stock_status`
- `sort`: `price_asc` | `price_desc` | (default: newest)
- `page`, `limit` (max 100)

### Invites
| Method | Path | Description |
|--------|------|-------------|
| GET | `/invites/validate?code=KYS-XXXX` | Validate invite code |

### Farmer Applications
| Method | Path | Description |
|--------|------|-------------|
| POST | `/farmer-applications` | Submit application |
| POST | `/uploads/application-video/presigned-url` | Get S3 upload URL |

---

## Farmer Endpoints (`/farmer/*` — Bearer JWT, role=farmer, status=active)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/farmer/profile` | Get own profile |
| PUT | `/farmer/profile` | Update profile |
| GET | `/farmer/products` | Own product list |
| POST | `/farmer/products` | Create product (pending review) |
| GET | `/farmer/products/:id` | Get own product |
| PUT | `/farmer/products/:id` | Update product |
| PATCH | `/farmer/products/:id/status` | Set stock_status |
| GET | `/farmer/invites` | Own invite codes |
| POST | `/farmer/uploads/product-image` | Upload product image |
| POST | `/farmer/uploads/profile-image` | Upload profile image |

---

## Admin Endpoints (`/admin/*` — Bearer JWT, role=admin)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/dashboard` | Stats (farmers, pending apps, products) |
| GET | `/admin/applications` | List applications (filter: `?status=pending`) |
| GET | `/admin/applications/:id` | Application detail + video URL |
| POST | `/admin/applications/:id/approve` | Approve → create user + farmer_profile |
| POST | `/admin/applications/:id/reject` | Reject with reason |
| POST | `/admin/applications/:id/request-video` | Request video upload |
| GET | `/admin/farmers` | All farmers |
| GET | `/admin/farmers/:id` | Farmer detail |
| POST | `/admin/farmers/:id/suspend` | Suspend farmer |
| POST | `/admin/farmers/:id/reactivate` | Reactivate farmer |
| PATCH | `/admin/farmers/:id/founding` | Set founding farmer flag |
| PATCH | `/admin/farmers/:id/invite-quota` | Update invite quota |
| GET | `/admin/products` | All products |
| GET | `/admin/products/:id` | Product detail |
| POST | `/admin/products/:id/approve` | Set status=active |
| POST | `/admin/products/:id/reject` | Set status=rejected |
| POST | `/admin/products/:id/hide` | Set status=hidden |
| DELETE | `/admin/products/:id` | Delete product |
| GET | `/admin/categories` | All categories |
| POST | `/admin/categories` | Create category |
| PUT | `/admin/categories/:id` | Update category |
| DELETE | `/admin/categories/:id` | Soft-delete category |

---

## Pagination Response Format

```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 42,
    "total_pages": 3
  }
}
```

## Error Codes

See [ERROR_FORMAT.md](ERROR_FORMAT.md) for full list.
