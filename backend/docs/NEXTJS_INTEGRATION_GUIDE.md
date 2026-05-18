# Next.js Integration Guide — Köyden Şehre API

For Next.js 14+ App Router frontends.

---

## Setup

```bash
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:8080/api/v1
API_URL=http://localhost:8080/api/v1  # server-side
```

---

## API Client

```typescript
// lib/api.ts
const API = process.env.NEXT_PUBLIC_API_URL!;

type ApiResponse<T> = {
  success: boolean;
  data?: T;
  message?: string;
  error?: { code: string; message: string };
  pagination?: { page: number; limit: number; total: number; total_pages: number };
};

export async function apiFetch<T>(
  path: string,
  options?: RequestInit & { token?: string }
): Promise<ApiResponse<T>> {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (options?.token) headers['Authorization'] = `Bearer ${options.token}`;

  const res = await fetch(`${API}${path}`, { ...options, headers });
  return res.json();
}
```

---

## Public Data (Server Components)

```typescript
// app/page.tsx
import { apiFetch } from '@/lib/api';

export default async function Home() {
  const { data: products } = await apiFetch<Product[]>('/products?limit=20', {
    next: { revalidate: 60 },  // ISR: revalidate every 60s
  });

  return <ProductGrid products={products ?? []} />;
}
```

```typescript
// app/categories/page.tsx
const { data: categories } = await apiFetch<Category[]>('/categories', {
  next: { revalidate: 3600 },
});
```

---

## Categories (with children)

```typescript
type Category = {
  id: string;
  name: string;
  slug: string;
  parent_id: string | null;
  sort_order: number;
  is_active: boolean;
  children?: Category[];
};

const { data } = await apiFetch<Category[]>('/categories');
// data is already a tree: root categories with .children populated
```

---

## Auth (NextAuth or custom)

### Custom JWT approach:

```typescript
// app/api/auth/login/route.ts
export async function POST(req: Request) {
  const body = await req.json();
  const result = await apiFetch<{ access_token: string; user: User }>('/auth/login', {
    method: 'POST',
    body: JSON.stringify(body),
  });

  if (!result.success) {
    return Response.json(result, { status: 401 });
  }

  const res = Response.json(result);
  res.headers.set('Set-Cookie',
    `token=${result.data!.access_token}; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=86400`
  );
  return res;
}
```

```typescript
// lib/auth.ts — read token from cookie (server)
import { cookies } from 'next/headers';

export function getToken(): string | undefined {
  return cookies().get('token')?.value;
}
```

---

## Protected Routes (Farmer Dashboard)

```typescript
// app/farmer/dashboard/page.tsx
import { getToken } from '@/lib/auth';
import { redirect } from 'next/navigation';

export default async function DashboardPage() {
  const token = getToken();
  if (!token) redirect('/login');

  const { data: profile } = await apiFetch<FarmerProfile>('/farmer/profile', { token });
  const { data: products } = await apiFetch<Product[]>('/farmer/products', { token });

  return <FarmerDashboard profile={profile} products={products ?? []} />;
}
```

---

## OTP + Application Form (Client Component)

```typescript
'use client';

export function ApplicationForm() {
  const [step, setStep] = useState<'phone' | 'otp' | 'form'>('phone');

  async function sendOtp(phone: string) {
    const res = await fetch('/api/v1/otp/send', {
      method: 'POST',
      body: JSON.stringify({ phone }),
      headers: { 'Content-Type': 'application/json' },
    });
    if (res.ok) setStep('otp');
  }

  async function verifyOtp(phone: string, code: string) {
    const res = await fetch('/api/v1/otp/verify', {
      method: 'POST',
      body: JSON.stringify({ phone, code }),
      headers: { 'Content-Type': 'application/json' },
    });
    const json = await res.json();
    if (json.success) setStep('form');
  }

  async function submitApplication(data: ApplicationData) {
    const res = await fetch('/api/v1/farmer-applications', {
      method: 'POST',
      body: JSON.stringify(data),
      headers: { 'Content-Type': 'application/json' },
    });
    return res.json();
  }
  // ...
}
```

---

## Image Upload Flow

```typescript
async function uploadProductImage(file: File, token: string) {
  // 1. Get presigned URL
  const { data } = await apiFetch<{ upload_url: string; key: string }>(
    '/farmer/uploads/product-image',
    { method: 'POST', token, body: JSON.stringify({ content_type: file.type }) }
  );

  // 2. Upload directly to R2/S3
  await fetch(data!.upload_url, { method: 'PUT', body: file });

  // 3. Return key for use in product creation
  return data!.key;
}
```

---

## Types Reference

```typescript
type Product = {
  id: string; title: string; description: string;
  price: number; unit: string;
  city: string; district: string; village: string;
  status: 'pending'|'active'|'rejected'|'hidden';
  stock_status: 'available'|'out_of_stock'|'limited';
  created_at: string;
  images: { url: string; sort_order: number }[];
  category: { id: string; name: string; slug: string; parent?: { id: string; name: string; slug: string } };
  farmer: { id: string; display_name: string; city: string; district: string; is_verified: boolean; is_founding_farmer: boolean; profile_image_url: string|null; public_phone: string|null };
};

type Pagination = { page: number; limit: number; total: number; total_pages: number };
```
