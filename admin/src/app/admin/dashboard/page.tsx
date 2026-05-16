"use client";

import { useQuery } from "@tanstack/react-query";
import {
  Activity,
  AlertCircle,
  CheckCircle2,
  Clock,
  Database,
  Globe,
  HardDrive,
  MessageSquare,
  ShieldAlert,
  Users,
} from "lucide-react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Line,
  LineChart,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { PageHeader } from "@/components/admin/PageHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { adminApi } from "@/lib/api";
import { cn } from "@/lib/utils";

const COLORS = ["#10b981", "#3b82f6", "#f59e0b", "#ef4444", "#8b5cf6", "#ec4899"];

export default function DashboardPage() {
  const { data, isLoading, isError } = useQuery({
    queryKey: ["dashboard"],
    queryFn: () => adminApi.getDashboard(),
  });

  if (isLoading) {
    return (
      <div className="space-y-6">
        <PageHeader title="Dashboard" description="Güven, kalite ve operasyon merkezi" />
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="h-32 animate-pulse rounded-xl bg-stone-100 dark:bg-stone-800" />
          ))}
        </div>
      </div>
    );
  }

  if (isError || !data) {
    return (
      <div className="rounded-md border border-red-200 bg-red-50 p-4 text-red-700 dark:border-red-900/50 dark:bg-red-900/20 dark:text-red-400">
        Veriler yüklenirken bir hata oluştu.
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <PageHeader
        title="Dashboard"
        description="Sistemdeki genel operasyonel durum ve metrikler."
      />

      {/* KPI Cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6">
        <MetricCard
          title="Bekleyen Başvurular"
          value={data.stats.pending_applications}
          icon={Clock}
          trend={data.stats.today_applications > 0 ? `+${data.stats.today_applications} bugün` : null}
        />
        <MetricCard title="Aktif Çiftçiler" value={data.stats.active_farmers} icon={Users} />
        <MetricCard
          title="Bekleyen Ürünler"
          value={data.stats.pending_products}
          icon={ShieldAlert}
        />
        <MetricCard title="Yayındaki Ürünler" value={data.stats.active_products} icon={CheckCircle2} />
        <MetricCard
          title="Askıya Alınanlar"
          value={data.stats.suspended_farmers}
          icon={AlertCircle}
        />
        <MetricCard title="Bugünkü Başvurular" value={data.stats.today_applications} icon={Activity} />
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Line Chart */}
        <Card className="col-span-1 lg:col-span-2 shadow-sm">
          <CardHeader>
            <CardTitle className="text-sm font-medium">Son 7 Gün Başvuru Trendi</CardTitle>
          </CardHeader>
          <CardContent className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={data.applicationsByDay}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: "#6b7280" }} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: "#6b7280" }} />
                <Tooltip
                  contentStyle={{ borderRadius: "8px", border: "none", boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.1)" }}
                />
                <Line type="monotone" dataKey="value" stroke="#10b981" strokeWidth={3} dot={{ r: 4, strokeWidth: 2 }} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Platform Health */}
        <Card className="col-span-1 shadow-sm">
          <CardHeader>
            <CardTitle className="text-sm font-medium">Platform Sağlığı</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {data.health.map((item) => {
                let Icon = Globe;
                if (item.name === "API") Icon = Globe;
                if (item.name === "PostgreSQL") Icon = Database;
                if (item.name === "Redis") Icon = Activity;
                if (item.name === "Storage") Icon = HardDrive;
                if (item.name === "SMS") Icon = MessageSquare;

                return (
                  <div key={item.name} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div
                        className={`flex h-8 w-8 items-center justify-center rounded-full ${
                          item.status === "operational"
                            ? "bg-emerald-100 text-emerald-600 dark:bg-emerald-900/30"
                            : item.status === "warning"
                            ? "bg-amber-100 text-amber-600 dark:bg-amber-900/30"
                            : "bg-red-100 text-red-600 dark:bg-red-900/30"
                        }`}
                      >
                        <Icon className="h-4 w-4" />
                      </div>
                      <span className="text-sm font-medium">{item.name}</span>
                    </div>
                    <div className="text-right">
                      <span
                        className={`text-sm ${
                          item.status === "operational"
                            ? "text-emerald-600 dark:text-emerald-400"
                            : item.status === "warning"
                            ? "text-amber-600 dark:text-amber-400"
                            : "text-red-600 dark:text-red-400"
                        }`}
                      >
                        {item.status === "operational" ? "Aktif" : item.status === "warning" ? "Uyarı" : "Hata"}
                      </span>
                      {item.note && <p className="text-xs text-stone-500">{item.note}</p>}
                    </div>
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* Pie Chart */}
        <Card className="shadow-sm">
          <CardHeader>
            <CardTitle className="text-sm font-medium">Kategoriye Göre Ürünler</CardTitle>
          </CardHeader>
          <CardContent className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={data.productsByCategory}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={80}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {data.productsByCategory.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{ borderRadius: "8px", border: "none", boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.1)" }}
                />
              </PieChart>
            </ResponsiveContainer>
            <div className="mt-4 flex flex-wrap justify-center gap-4">
              {data.productsByCategory.map((entry, index) => (
                <div key={entry.name} className="flex items-center gap-2">
                  <div className="h-3 w-3 rounded-full" style={{ backgroundColor: COLORS[index % COLORS.length] }} />
                  <span className="text-xs text-stone-600 dark:text-stone-400">{entry.name}</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Bar Chart */}
        <Card className="shadow-sm">
          <CardHeader>
            <CardTitle className="text-sm font-medium">Şehirlere Göre Üreticiler</CardTitle>
          </CardHeader>
          <CardContent className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data.producersByCity}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: "#6b7280" }} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: "#6b7280" }} />
                <Tooltip
                  cursor={{ fill: "rgba(0,0,0,0.05)" }}
                  contentStyle={{ borderRadius: "8px", border: "none", boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.1)" }}
                />
                <Bar dataKey="value" fill="#10b981" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

function MetricCard({
  title,
  value,
  icon: Icon,
  trend,
  className,
}: {
  title: string;
  value: string | number;
  icon: any;
  trend?: string | null;
  className?: string;
}) {
  return (
    <div className={cn(
      "relative overflow-hidden rounded-2xl border border-stone-200 bg-white p-6 shadow-sm transition-all hover:shadow-md dark:border-stone-800 dark:bg-stone-900",
      className
    )}>
      <div className="absolute -right-4 -top-4 opacity-5 dark:opacity-10 pointer-events-none">
        <Icon className="h-24 w-24" />
      </div>
      <div className="relative z-10 flex items-center justify-between">
        <p className="text-sm font-medium text-stone-500 dark:text-stone-400">{title}</p>
        <div className="flex h-10 w-10 items-center justify-center rounded-full bg-stone-50 dark:bg-stone-800/50">
          <Icon className="h-5 w-5 text-stone-700 dark:text-stone-300" />
        </div>
      </div>
      <div className="relative z-10 mt-4 flex items-baseline gap-3">
        <p className="text-3xl font-bold tracking-tight text-stone-900 dark:text-white">{value}</p>
        {trend && (
          <span className="inline-flex items-center rounded-full bg-emerald-50 px-2 py-0.5 text-xs font-semibold text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400">
            {trend}
          </span>
        )}
      </div>
    </div>
  );
}
