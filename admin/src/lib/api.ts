import axios from "axios";
import { useAuthStore } from "./store";
import {
  Application,
  Category,
  CityDensity,
  DashboardData,
  Farmer,
  InviteNode,
  Product,
  ProductStatus,
} from "./types";

export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8080/api/v1";

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 7000,
});

api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

const delay = (ms = 350) => new Promise((resolve) => setTimeout(resolve, ms));

const applications: Application[] = [
  {
    id: "app-1",
    full_name: "Ayse Yilmaz",
    phone: "05321112233",
    business_name: "Yilmaz Cilek Bahcesi",
    producer_type: "family_producer",
    city: "Bursa",
    district: "Kestel",
    village: "Saitabat",
    product_examples: "Cilek, ahududu, recel",
    status: "pending",
    invite_code: "KYS-BRS-104",
    invite_trust: "trusted",
    risk_level: "low",
    profile_description:
      "Uc kusaktir Kestel'de cilek ve orman meyveleri ureten aile isletmesi.",
    video_url: "https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4",
    created_at: "2026-05-16T07:40:00.000Z",
    admin_notes: "Davet zinciri guclu, video ve konum tutarli.",
  },
  {
    id: "app-2",
    full_name: "Mehmet Demir",
    phone: "05445556677",
    business_name: "Demir Sut Urunleri",
    producer_type: "cooperative",
    city: "Balikesir",
    district: "Susurluk",
    village: "Merkez",
    product_examples: "Peynir, yogurt, tereyagi",
    status: "pending",
    invite_code: "KYS-NEW-882",
    invite_trust: "unknown",
    risk_level: "medium",
    profile_description: "Sut urunleri.",
    created_at: "2026-05-15T11:18:00.000Z",
    admin_notes: "Video bekleniyor, davet gecmisi yeni.",
  },
  {
    id: "app-3",
    full_name: "Fatma Kaya",
    phone: "05550001122",
    business_name: "Kaya Bal",
    producer_type: "individual",
    city: "Mugla",
    district: "Ula",
    village: "Yesilova",
    product_examples: "Cam bali, propolis",
    status: "approved",
    invite_code: "KYS-FOUNDER",
    invite_trust: "trusted",
    risk_level: "low",
    profile_description:
      "Gezgin aricilik yapan ve parti bazli analiz raporu sunan uretici.",
    video_url: "https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4",
    created_at: "2026-05-13T15:25:00.000Z",
  },
  {
    id: "app-4",
    full_name: "Hasan Cinar",
    phone: "05078889900",
    business_name: "Cinar Bahce",
    producer_type: "family_producer",
    city: "Konya",
    district: "Meram",
    village: "Hatip",
    product_examples: "Elma, havuc",
    status: "rejected",
    invite_code: "KYS-LOW-711",
    invite_trust: "weak",
    risk_level: "high",
    profile_description: "Uretim.",
    created_at: "2026-05-12T08:00:00.000Z",
    admin_notes: "Profil ve davet zinciri yetersiz.",
  },
];

const products: Product[] = [
  {
    id: "prd-1",
    farmer_id: "frm-1",
    farmer_name: "Ayse Yilmaz",
    category_id: "cat-1-1",
    category_name: "Meyve",
    title: "Dag Cilegi",
    description: "Gunluk toplanan, dogal kokulu dag cilegi.",
    price: 165,
    unit: "kg",
    stock: 42,
    status: "pending",
    city: "Bursa",
    image_urls: ["https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=900&q=80"],
    created_at: "2026-05-16T09:00:00.000Z",
    moderation_tags: ["Yeni uretici urunu", "Gorsel kontrol gerekli"],
  },
  {
    id: "prd-2",
    farmer_id: "frm-2",
    farmer_name: "Mehmet Demir",
    category_id: "cat-2-1",
    category_name: "Sut Urunleri",
    title: "Taze Koy Peyniri",
    description: "Geleneksel salamura, gunluk sutten uretilir.",
    price: 280,
    unit: "kg",
    stock: 18,
    status: "active",
    city: "Balikesir",
    image_urls: ["https://images.unsplash.com/photo-1452195100486-9cc805987862?auto=format&fit=crop&w=900&q=80"],
    created_at: "2026-05-14T13:22:00.000Z",
    moderation_tags: ["Onayli uretici"],
  },
  {
    id: "prd-3",
    farmer_id: "frm-3",
    farmer_name: "Fatma Kaya",
    category_id: "cat-3-1",
    category_name: "Bal ve Recel",
    title: "Cam Bali",
    description: "Mugla cam ormanlarindan hasat.",
    price: 95,
    unit: "850g",
    stock: 64,
    status: "pending",
    city: "Mugla",
    image_urls: ["https://images.unsplash.com/photo-1587049352851-8d4e89133924?auto=format&fit=crop&w=900&q=80"],
    created_at: "2026-05-15T17:10:00.000Z",
    moderation_tags: ["Fiyat anormal", "Kategori dogru"],
  },
  {
    id: "prd-4",
    farmer_id: "frm-4",
    farmer_name: "Selin Arslan",
    category_id: "cat-4-1",
    category_name: "Sebze",
    title: "Organik Domates",
    description: "Acik tarla domatesi.",
    price: 72,
    unit: "kg",
    stock: 120,
    status: "hidden",
    city: "Antalya",
    image_urls: ["https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=900&q=80"],
    created_at: "2026-05-11T10:10:00.000Z",
    moderation_tags: ["Eksik bilgi"],
  },
];

const farmers: Farmer[] = [
  {
    id: "frm-1",
    full_name: "Ayse Yilmaz",
    phone: "05321112233",
    city: "Bursa",
    district: "Kestel",
    status: "active",
    is_founding_farmer: false,
    invite_code: "KYS-BRS-104",
    invite_quota: 4,
    trust_score: 91,
    products_count: 8,
    complaints_count: 0,
    profile_completion: 96,
    video_verified: true,
    approved_products: 7,
    invite_history: 3,
    admin_notes: "Hizli yanit veriyor, urun kalitesi tutarli.",
  },
  {
    id: "frm-2",
    full_name: "Mehmet Demir",
    phone: "05445556677",
    city: "Balikesir",
    district: "Susurluk",
    status: "active",
    is_founding_farmer: true,
    invite_code: "KYS-FOUNDER",
    invite_quota: 12,
    trust_score: 86,
    products_count: 11,
    complaints_count: 1,
    profile_completion: 88,
    video_verified: true,
    approved_products: 9,
    invite_history: 8,
  },
  {
    id: "frm-3",
    full_name: "Fatma Kaya",
    phone: "05550001122",
    city: "Mugla",
    district: "Ula",
    status: "active",
    is_founding_farmer: false,
    invite_code: "KYS-MGL-302",
    invite_quota: 5,
    trust_score: 94,
    products_count: 6,
    complaints_count: 0,
    profile_completion: 100,
    video_verified: true,
    approved_products: 6,
    invite_history: 2,
  },
  {
    id: "frm-4",
    full_name: "Hasan Cinar",
    phone: "05078889900",
    city: "Konya",
    district: "Meram",
    status: "suspended",
    is_founding_farmer: false,
    invite_code: "KYS-KNY-711",
    invite_quota: 0,
    trust_score: 42,
    products_count: 2,
    complaints_count: 4,
    profile_completion: 54,
    video_verified: false,
    approved_products: 1,
    invite_history: 0,
    admin_notes: "Fiyat ve teslimat sikayetleri nedeniyle askida.",
  },
];

const categories: Category[] = [
  {
    id: "cat-1",
    name: "Meyve",
    active: true,
    sort_order: 1,
    children: [
      { id: "cat-1-1", name: "Cilek", parent_id: "cat-1", active: true, sort_order: 1 },
      { id: "cat-1-2", name: "Elma", parent_id: "cat-1", active: true, sort_order: 2 },
    ],
  },
  {
    id: "cat-2",
    name: "Sut Urunleri",
    active: true,
    sort_order: 2,
    children: [
      { id: "cat-2-1", name: "Peynir", parent_id: "cat-2", active: true, sort_order: 1 },
      { id: "cat-2-2", name: "Yogurt", parent_id: "cat-2", active: true, sort_order: 2 },
    ],
  },
  {
    id: "cat-3",
    name: "Bal ve Recel",
    active: true,
    sort_order: 3,
    children: [{ id: "cat-3-1", name: "Bal", parent_id: "cat-3", active: true, sort_order: 1 }],
  },
];

const inviteNetwork: InviteNode = {
  id: "root",
  name: "KYS-FOUNDER",
  code: "KYS-FOUNDER",
  city: "Turkiye",
  trust_score: 100,
  children: [
    {
      id: "frm-2",
      name: "Mehmet Demir",
      code: "KYS-BLK-001",
      city: "Balikesir",
      trust_score: 86,
      children: [
        { id: "frm-1", name: "Ayse Yilmaz", code: "KYS-BRS-104", city: "Bursa", trust_score: 91 },
        { id: "frm-3", name: "Fatma Kaya", code: "KYS-MGL-302", city: "Mugla", trust_score: 94 },
      ],
    },
    { id: "frm-4", name: "Hasan Cinar", code: "KYS-KNY-711", city: "Konya", trust_score: 42 },
  ],
};

const cityDensity: CityDensity[] = [
  { city: "Bursa", farmers: 18, pending: 4, risk: "low" },
  { city: "Balikesir", farmers: 14, pending: 3, risk: "medium" },
  { city: "Mugla", farmers: 10, pending: 1, risk: "low" },
  { city: "Konya", farmers: 9, pending: 2, risk: "high" },
  { city: "Antalya", farmers: 7, pending: 1, risk: "medium" },
  { city: "Izmir", farmers: 6, pending: 0, risk: "low" },
];

async function withFallback<T>(request: () => Promise<T>, fallback: () => Promise<T>): Promise<T> {
  try {
    return await request();
  } catch {
    return fallback();
  }
}

export const adminApi = {
  login: async (phone: string, password: string) =>
    withFallback(
      async () => {
        const { data } = await api.post("/auth/login", { phone, password });
        return { token: data.token || data.access_token || data.data?.token };
      },
      async () => {
        await delay();
        if (phone.length >= 10 && password.length >= 4) {
          return { token: "mock-admin-jwt-token" };
        }
        throw new Error("Telefon veya sifre hatali");
      },
    ),

  getDashboard: async (): Promise<DashboardData> =>
    withFallback(
      async () => {
        const { data } = await api.get("/admin/dashboard");
        return data.data || data;
      },
      async () => {
        await delay();
        return {
          stats: {
            pending_applications: applications.filter((item) => item.status === "pending").length,
            active_farmers: farmers.filter((item) => item.status === "active").length,
            pending_products: products.filter((item) => item.status === "pending").length,
            active_products: products.filter((item) => item.status === "active").length,
            suspended_farmers: farmers.filter((item) => item.status === "suspended").length,
            today_applications: 1,
          },
          applicationsByDay: [
            { name: "Pzt", value: 4 },
            { name: "Sal", value: 3 },
            { name: "Car", value: 7 },
            { name: "Per", value: 2 },
            { name: "Cum", value: 6 },
            { name: "Cmt", value: 8 },
            { name: "Paz", value: 5 },
          ],
          productsByCategory: [
            { name: "Meyve", value: 34 },
            { name: "Sebze", value: 28 },
            { name: "Sut", value: 18 },
            { name: "Bal", value: 12 },
          ],
          producersByCity: cityDensity.map((item) => ({ name: item.city, value: item.farmers })),
          health: [
            { name: "API", status: "operational" },
            { name: "PostgreSQL", status: "operational" },
            { name: "Redis", status: "operational" },
            { name: "Storage", status: "operational" },
            { name: "SMS", status: "warning", note: "Teslimatta gecikme" },
          ],
        };
      },
    ),

  getApplications: async () =>
    withFallback(async () => (await api.get("/admin/applications")).data.data, async () => (await delay(), applications)),
  getApplication: async (id: string) =>
    withFallback(async () => (await api.get(`/admin/applications/${id}`)).data.data, async () => {
      await delay();
      return applications.find((item) => item.id === id) || applications[0];
    }),
  reviewApplication: async (id: string, action: "approve" | "reject" | "request_video", reason?: string) =>
    withFallback(async () => (await api.post(`/admin/applications/${id}/${action}`, { reason })).data, async () => {
      await delay(250);
      return { ok: true };
    }),

  getProducts: async () =>
    withFallback(async () => (await api.get("/admin/products")).data.data, async () => (await delay(), products)),
  getProduct: async (id: string) =>
    withFallback(async () => (await api.get(`/admin/products/${id}`)).data.data, async () => {
      await delay();
      return products.find((item) => item.id === id) || products[0];
    }),
  moderateProduct: async (id: string, status: ProductStatus, reason?: string) =>
    withFallback(async () => (await api.post(`/admin/products/${id}/moderate`, { status, reason })).data, async () => {
      await delay(250);
      return { ok: true };
    }),

  getFarmers: async () =>
    withFallback(async () => (await api.get("/admin/farmers")).data.data, async () => (await delay(), farmers)),
  getFarmer: async (id: string) =>
    withFallback(async () => (await api.get(`/admin/farmers/${id}`)).data.data, async () => {
      await delay();
      return farmers.find((item) => item.id === id) || farmers[0];
    }),
  updateFarmer: async (id: string, payload: Partial<Farmer>) =>
    withFallback(async () => (await api.patch(`/admin/farmers/${id}`, payload)).data, async () => {
      await delay(250);
      return { ok: true };
    }),

  getCategories: async () =>
    withFallback(async () => (await api.get("/admin/categories")).data.data, async () => (await delay(), categories)),
  getInviteNetwork: async () =>
    withFallback(async () => (await api.get("/admin/invite-network")).data.data, async () => (await delay(), inviteNetwork)),
  getCityDensity: async () =>
    withFallback(async () => (await api.get("/admin/map")).data.data, async () => (await delay(), cityDensity)),
};

export default api;
