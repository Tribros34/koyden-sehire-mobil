# Error Format — Köyden Şehre API

All errors return HTTP status codes with a consistent body:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message in Turkish"
  }
}
```

---

## HTTP Status Codes

| Status | Meaning |
|--------|---------|
| 200 | OK |
| 201 | Created |
| 400 | Bad Request (validation, invalid input) |
| 401 | Unauthorized (missing/invalid token) |
| 403 | Forbidden (wrong role) |
| 404 | Not Found |
| 409 | Conflict (duplicate) |
| 429 | Too Many Requests (rate limit) |
| 500 | Internal Server Error |

---

## Error Codes

### Auth
| Code | Status | Description |
|------|--------|-------------|
| `UNAUTHORIZED` | 401 | Missing or invalid JWT |
| `FORBIDDEN` | 403 | Insufficient role |
| `INVALID_CREDENTIALS` | 401 | Wrong phone/password |
| `ACCOUNT_INACTIVE` | 403 | User suspended |

### OTP
| Code | Status | Description |
|------|--------|-------------|
| `INVALID_PHONE` | 400 | Phone format invalid (must be 05XXXXXXXXX) |
| `COOLDOWN_ACTIVE` | 429 | Too soon to resend |
| `OTP_EXPIRED` | 400 | OTP not found or expired |
| `INVALID_CODE` | 400 | Wrong code (includes remaining attempts) |
| `MAX_ATTEMPTS` | 400 | Too many wrong attempts |

### Invite Codes
| Code | Status | Description |
|------|--------|-------------|
| `INVALID_CODE_FORMAT` | 400 | Code doesn't match KYS-XXXXXX pattern |
| `INVALID_CODE` | 404 | Code not found |
| `CODE_EXPIRED` | 400 | Code inactive, full, or expired |

### Farmer Applications
| Code | Status | Description |
|------|--------|-------------|
| `BAD_REQUEST` | 400 | Missing fields, invalid invite code, phone not verified |
| `CONFLICT` | 409 | Phone already registered or has active application |

### Admin
| Code | Status | Description |
|------|--------|-------------|
| `NOT_FOUND` | 404 | Application/product not found |
| `INVALID_STATUS` | 400 | Cannot approve/reject in current status |
| `USER_EXISTS` | 409 | Phone already has a user account |

### General
| Code | Status | Description |
|------|--------|-------------|
| `NOT_FOUND` | 404 | Resource not found |
| `INTERNAL_ERROR` | 500 | Unexpected server error |
| `BAD_REQUEST` | 400 | Generic validation failure |
