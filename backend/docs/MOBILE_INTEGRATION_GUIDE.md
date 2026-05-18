# Mobile Integration Guide — Köyden Şehre API

For React Native / Flutter / native iOS/Android clients.

---

## Base URL

```
Production: https://api.koydensehire.com/api/v1
Development: http://localhost:8080/api/v1
```

---

## Auth Flow (Mobile)

### Step 1 — Send OTP
```
POST /otp/send
Body: {"phone": "05XXXXXXXXX"}
```

### Step 2 — Verify OTP
```
POST /otp/verify
Body: {"phone": "05XXXXXXXXX", "code": "123456"}
```
Store verified flag in app state (expires after 30min server-side).

### Step 3 — Submit Application
```
POST /farmer-applications
Body: {full registration body}
```
On success, save `application_id`.

### Step 4 — Login after approval
```
POST /auth/login
Body: {"phone": "05XXXXXXXXX", "password": "..."}
Response: {"access_token": "eyJ...", "user": {...}}
```
Store token in SecureStorage / Keychain.

### Step 5 — Authenticated requests
```
Authorization: Bearer <access_token>
```

---

## Token Storage

- **iOS:** Use `Keychain`
- **Android:** Use `EncryptedSharedPreferences` or `Keystore`
- **React Native:** Use `react-native-keychain` or `expo-secure-store`

**Do not store tokens in AsyncStorage** (unencrypted).

---

## Key Screens & Endpoints

### Home / Product Feed
```
GET /products?page=1&limit=20
GET /products?category_id=UUID&city=Bursa
GET /categories  (for filter chips)
```

### Product Detail
```
GET /products/:id
```

### Farmer Profile
```
GET /farmers/:id
GET /farmers/:id/products
```

### Apply as Farmer
```
GET /invites/validate?code=KYS-XXXX  (validate before showing form)
POST /otp/send → POST /otp/verify → POST /farmer-applications
```

### Farmer Dashboard (after login)
```
GET /farmer/profile
GET /farmer/products
POST /farmer/products
GET /farmer/invites
```

---

## Image Uploads (Presigned URLs)

### Product Image
```
POST /farmer/uploads/product-image
Body: {"content_type": "image/jpeg"}
Response: {"upload_url": "https://...", "key": "..."}

→ PUT <upload_url> with image binary (no auth header)
→ Use key in POST /farmer/products as image_urls[0]
```

### Application Video
```
POST /uploads/application-video/presigned-url
Body: {"phone": "...", "invite_code": "...", "content_type": "video/mp4"}
Response: {"upload_url": "...", "key": "..."}

→ PUT <upload_url> with video binary
→ Use key in POST /farmer-applications as application_video_key
```

---

## Error Handling

Always check `success` field:
```javascript
const res = await fetch(url, options);
const json = await res.json();
if (!json.success) {
  const { code, message } = json.error;
  // Show message to user
  // Handle specific codes:
  if (code === 'COOLDOWN_ACTIVE') showRetryTimer();
  if (code === 'INVALID_CODE') showRemainingAttempts(message);
  if (code === 'UNAUTHORIZED') redirectToLogin();
}
```

---

## Pagination

```javascript
// Load more pattern
const response = await fetch(`/products?page=${page}&limit=20`);
const { data, pagination } = response;
const hasMore = pagination.page < pagination.total_pages;
```

---

## Rate Limits

| Endpoint | Limit |
|----------|-------|
| OTP Send | 1 per 60s per phone |
| OTP Verify | 3 attempts per code |
| Invite Validate | 10 per minute per IP |

Return HTTP 429 when exceeded. Show countdown timer based on retry-after.
