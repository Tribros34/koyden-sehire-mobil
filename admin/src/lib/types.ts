export type ApplicationStatus = "pending" | "approved" | "rejected" | "needs_video";
export type ProductStatus = "pending" | "active" | "rejected" | "hidden" | "passive";
export type FarmerStatus = "active" | "suspended";
export type RiskLevel = "low" | "medium" | "high";
export type HealthStatus = "operational" | "warning" | "down";

export interface DashboardStats {
  pending_applications: number;
  active_farmers: number;
  pending_products: number;
  active_products: number;
  suspended_farmers: number;
  today_applications: number;
}

export interface ChartPoint {
  name: string;
  value: number;
}

export interface DashboardData {
  stats: DashboardStats;
  applicationsByDay: ChartPoint[];
  productsByCategory: ChartPoint[];
  producersByCity: ChartPoint[];
  health: PlatformHealthItem[];
}

export interface PlatformHealthItem {
  name: string;
  status: HealthStatus;
  note?: string;
}

export interface Application {
  id: string;
  full_name: string;
  phone: string;
  business_name: string;
  producer_type: string;
  city: string;
  district: string;
  village?: string | null;
  product_examples?: string | null;
  status: ApplicationStatus;
  created_at: string;
  invite_code?: string | null;
  invite_trust?: "trusted" | "unknown" | "weak";
  risk_level?: RiskLevel;
  profile_description?: string;
  video_url?: string | null;
  admin_notes?: string | null;
}

export interface TimelineItem {
  title: string;
  description: string;
  date: string;
  status: "done" | "current" | "muted";
}

export interface ProductImage {
  url: string;
}

export interface Product {
  id: string;
  title: string;
  description?: string | null;
  price: number;
  unit: string;
  city: string;
  district?: string | null;
  village?: string | null;
  status: ProductStatus;
  stock_status?: "available" | "out_of_stock" | string;
  created_at: string;
  images?: ProductImage[];
  farmer?: {
    id: string;
    display_name: string;
    city?: string;
    district?: string;
    is_verified?: boolean;
    is_founding_farmer?: boolean;
    profile_image_url?: string | null;
    public_phone?: string | null;
  };
  category?: {
    id: string;
    name: string;
    slug: string;
    parent?: { id: string; name: string; slug: string } | null;
  };
}

export interface Farmer {
  id: string;
  full_name: string;
  phone: string;
  city: string;
  district: string;
  status: FarmerStatus;
  is_founding_farmer: boolean;
  invite_code: string;
  invite_quota: number;
  trust_score: number;
  products_count: number;
  complaints_count: number;
  profile_completion: number;
  video_verified: boolean;
  approved_products: number;
  invite_history: number;
  admin_notes?: string;
}

export interface Category {
  id: string;
  name: string;
  parent_id?: string;
  active: boolean;
  sort_order: number;
  children?: Category[];
}

export interface InviteNode {
  id: string;
  name: string;
  code: string;
  city: string;
  trust_score: number;
  children?: InviteNode[];
}

export interface CityDensity {
  city: string;
  farmers: number;
  pending: number;
  risk: RiskLevel;
}
