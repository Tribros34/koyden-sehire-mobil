# Uploads & Storage — Köyden Şehre

The backend uses Cloudflare R2 (S3-compatible) for all media storage.

---

## Architecture

```
Client → GET presigned PUT URL from API
       → PUT file directly to R2 (no backend in the middle)
       → Save returned key in product/application record
```

Files are served via a public CDN URL (`STORAGE_PUBLIC_URL`).

---

## Presigned URL Flow

### 1. Request presigned URL

**Product Image (authenticated farmer):**
```
POST /farmer/uploads/product-image
Authorization: Bearer <token>
Body: {"content_type": "image/jpeg"}

Response:
{
  "success": true,
  "data": {
    "upload_url": "https://r2.example.com/bucket/path?X-Amz-Signature=...",
    "key": "products/images/farmer-id/1234567890.jpg"
  }
}
```

**Application Video (unauthenticated, phone+invite verified):**
```
POST /uploads/application-video/presigned-url
Body: {
  "phone": "05XXXXXXXXX",
  "invite_code": "KYS-XXXXXX",
  "content_type": "video/mp4"
}
Response: {"upload_url": "...", "key": "application-videos/pending/05XX.../1234567890.mp4"}
```

**Profile Image (authenticated farmer):**
```
POST /farmer/uploads/profile-image
Authorization: Bearer <token>
Body: {"content_type": "image/jpeg"}
```

### 2. Upload to R2

```bash
curl -X PUT "<upload_url>" \
  -H "Content-Type: image/jpeg" \
  --data-binary @photo.jpg
```

No `Authorization` header needed — the presigned URL contains auth.

### 3. Use the key

When creating a product:
```json
{
  "image_urls": ["https://cdn.koydensehire.com/products/images/farmer-id/1234567890.jpg"]
}
```

When submitting application with video:
```json
{
  "application_video_key": "application-videos/pending/05XX.../1234567890.mp4"
}
```

---

## Storage Key Patterns

| Type | Pattern |
|------|---------|
| Product images | `products/images/{farmer_id}/{timestamp}.{ext}` |
| Profile images | `profiles/{user_id}/{timestamp}.{ext}` |
| Application videos | `application-videos/pending/{phone}/{timestamp}.mp4` |
| Approved videos | `application-videos/approved/{application_id}.mp4` |

---

## Presigned URL Expiry

| Endpoint | URL expiry |
|----------|-----------|
| Product/profile image PUT | 15 minutes |
| Application video PUT | 15 minutes |
| Application video GET (admin) | 1 hour |

---

## Accepted Content Types

| Category | Accepted types |
|----------|---------------|
| Images | `image/jpeg`, `image/png`, `image/webp` |
| Videos | `video/mp4`, `video/quicktime` |

Validate `content_type` on the client before requesting a presigned URL.

---

## File Size Recommendations

| Type | Max recommended |
|------|----------------|
| Product image | 5 MB |
| Profile image | 2 MB |
| Application video | 100 MB |

---

## No-op Provider (Development)

If `STORAGE_ENDPOINT` is not configured, the backend uses a no-op storage provider.  
Presigned URLs will be empty strings — upload calls will fail gracefully.  
Set real R2 credentials to test upload flows locally.

---

## Environment Variables

```bash
STORAGE_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
STORAGE_BUCKET=koydensehire
STORAGE_ACCESS_KEY=...
STORAGE_SECRET_KEY=...
STORAGE_PUBLIC_URL=https://cdn.koydensehire.com
```
