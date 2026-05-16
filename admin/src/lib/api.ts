import axios from "axios";
import { useAuthStore } from "./store";
import { Application, Category, CityDensity, DashboardData, Farmer, InviteNode, Product } from "./types";

export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8080/api/v1";

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
});

api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      useAuthStore.getState().logout();
      if (typeof window !== "undefined") {
        window.location.href = "/login";
      }
    }
    const message =
      error.response?.data?.error?.message ||
      error.message ||
      "Bir hata oluştu";
    console.error("[API]", error.response?.data?.error?.code, message);
    return Promise.reject(new Error(message));
  },
);

export const adminApi = {
  login: async (phone: string, password: string) => {
    const { data } = await api.post("/auth/login", { phone, password });
    if (!data.success) {
      throw new Error(data.error?.message || "Giriş başarısız");
    }
    const user = data.data?.user;
    if (user?.role !== "admin") {
      throw new Error("Bu panel yalnızca yöneticiler içindir.");
    }
    return { token: data.data.access_token as string, user };
  },

  getDashboard: async (): Promise<DashboardData> => {
    const [pendingAppsRes, pendingProdsRes, allProdsRes] =
      await Promise.all([
        api.get("/admin/applications", { params: { page: 1, limit: 1, status: "pending" } }),
        api.get("/admin/products", { params: { page: 1, limit: 1, status: "pending" } }),
        api.get("/admin/products", { params: { page: 1, limit: 1 } }),
      ]);

    return {
      stats: {
        pending_applications: pendingAppsRes.data.pagination?.total ?? 0,
        active_farmers: 0,
        pending_products: pendingProdsRes.data.pagination?.total ?? 0,
        active_products: allProdsRes.data.pagination?.total ?? 0,
        suspended_farmers: 0,
        today_applications: 0,
      },
      applicationsByDay: [],
      productsByCategory: [],
      producersByCity: [],
      health: [],
    };
  },

  getApplications: async (params?: { status?: string; page?: number; limit?: number }) => {
    const { data } = await api.get("/admin/applications", { params });
    return (data.data ?? []) as Application[];
  },

  getApplication: async (id: string) => {
    const { data } = await api.get(`/admin/applications/${id}`);
    return data.data as Application;
  },

  reviewApplication: async (
    id: string,
    action: "approve" | "reject",
    reason?: string,
  ) => {
    const body =
      action === "approve"
        ? { is_founding_farmer: true, invite_quota: 5 }
        : { reason: reason ?? "" };
    const { data } = await api.post(`/admin/applications/${id}/${action}`, body);
    return data;
  },

  getProducts: async (params?: { status?: string; page?: number; limit?: number }) => {
    const { data } = await api.get("/admin/products", { params });
    return (data.data ?? []) as Product[];
  },

  getProduct: async (id: string) => {
    const { data } = await api.get(`/admin/products/${id}`);
    return data.data as Product;
  },

  moderateProduct: async (
    id: string,
    action: "approve" | "reject",
    reason?: string,
  ) => {
    const body = action === "reject" ? { reason: reason ?? "" } : {};
    const { data } = await api.post(`/admin/products/${id}/${action}`, body);
    return data;
  },

  getCategories: async () => {
    const { data } = await api.get("/categories");
    return (data.data ?? []) as Category[];
  },

  // These endpoints are not yet available in the backend.
  getFarmers: async (): Promise<Farmer[]> => {
    throw new Error("Bu özellik için backend endpointi henüz hazır değil.");
  },
  getFarmer: async (_id: string): Promise<Farmer> => {
    throw new Error("Bu özellik için backend endpointi henüz hazır değil.");
  },
  updateFarmer: async (_id: string, _payload: Partial<Farmer>): Promise<void> => {
    throw new Error("Bu özellik için backend endpointi henüz hazır değil.");
  },
  getInviteNetwork: async (): Promise<InviteNode> => {
    throw new Error("Bu özellik için backend endpointi henüz hazır değil.");
  },
  getCityDensity: async (): Promise<CityDensity[]> => {
    throw new Error("Bu özellik için backend endpointi henüz hazır değil.");
  },
};

export default api;
