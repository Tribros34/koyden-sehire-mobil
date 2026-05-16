export type ApplicationStatus = "pending" | "approved" | "rejected" | "needs_video";
export type ProductStatus = "pending" | "active" | "rejected" | "hidden";
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
  village: string;
  product_examples: string;
  status: ApplicationStatus;
  created_at: string;
  invite_code?: string;
  invite_trust?: "trusted" | "unknown" | "weak";
  risk_level: RiskLevel;
  profile_description: string;
  video_url?: string;
  admin_notes?: string;
}

export interface TimelineItem {
  title: string;
  description: string;
  date: string;
  status: "done" | "current" | "muted";
}

export interface Product {
  id: string;
  farmer_id: string;
  farmer_name: string;
  category_id: string;
  category_name: string;
  title: string;
  description: string;
  price: number;
  unit: string;
  stock: number;
  status: ProductStatus;
  city: string;
  created_at: string;
  image_urls: string[];
  moderation_tags: string[];
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
