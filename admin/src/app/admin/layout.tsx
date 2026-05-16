"use client";

import {
  Activity,
  LayoutDashboard,
  LogOut,
  Map as MapIcon,
  Menu,
  Moon,
  Network,
  Settings,
  ShieldCheck,
  Sun,
  Tags,
  Users,
  X,
  FileText,
} from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { ReactNode, useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { useAuthStore } from "@/lib/store";
import { cn } from "@/lib/utils";

const menuItems = [
  { name: "Dashboard", path: "/admin/dashboard", icon: LayoutDashboard },
  { name: "Başvurular", path: "/admin/applications", icon: FileText },
  { name: "Ürün Moderasyonu", path: "/admin/products", icon: ShieldCheck },
  { name: "Çiftçiler", path: "/admin/farmers", icon: Users },
  { name: "Kategoriler", path: "/admin/categories", icon: Tags },
  { name: "Davet Ağı", path: "/admin/invite-network", icon: Network },
  { name: "Harita", path: "/admin/map", icon: MapIcon },
  { name: "Platform Sağlığı", path: "/admin/dashboard", icon: Activity },
  { name: "Ayarlar", path: "/admin/dashboard", icon: Settings },
];

export default function AdminLayout({ children }: { children: ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const { token, logout } = useAuthStore();
  const [isSidebarOpen, setSidebarOpen] = useState(false);
  const [dark, setDark] = useState(false);

  useEffect(() => {
    if (!token) router.push("/login");
  }, [token, router]);

  useEffect(() => {
    document.documentElement.classList.toggle("dark", dark);
  }, [dark]);

  if (!token) return null;

  return (
    <div className="min-h-screen bg-stone-50 text-stone-950 dark:bg-stone-950 dark:text-stone-50 transition-colors duration-300">
      <div className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-stone-200 bg-white/90 px-4 backdrop-blur md:hidden dark:border-stone-800 dark:bg-stone-950/90">
        <div>
          <p className="font-bold">Köyden Şehire</p>
          <p className="text-xs text-stone-500">Yönetim Merkezi</p>
        </div>
        <Button variant="ghost" className="h-9 w-9 px-0" onClick={() => setSidebarOpen(!isSidebarOpen)}>
          {isSidebarOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </Button>
      </div>

      <aside
        className={cn(
          "fixed inset-y-0 left-0 z-40 flex w-72 -translate-x-full flex-col bg-gradient-to-b from-[#112d20] to-[#173d2b] border-r border-[#173d2b]/50 shadow-xl text-white transition-transform duration-300 ease-in-out md:translate-x-0",
          isSidebarOpen && "translate-x-0",
        )}
      >
        <div className="border-b border-white/10 p-6">
          <p className="text-2xl font-bold tracking-tight text-white/90">Köyden Şehire</p>
          <p className="mt-1 text-xs text-emerald-200/80">Güven, kalite ve operasyon</p>
        </div>
        <nav className="flex-1 space-y-1 overflow-y-auto p-3">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const active = pathname === item.path || (item.path !== "/admin/dashboard" && pathname.startsWith(item.path));
            return (
              <Link
                key={`${item.name}-${item.path}`}
                href={item.path}
                onClick={() => setSidebarOpen(false)}
                className={cn(
                  "flex items-center gap-3 rounded-md px-3 py-2.5 text-sm font-medium text-emerald-50 transition hover:bg-white/10",
                  active && "bg-white text-emerald-950 shadow-sm hover:bg-white",
                )}
              >
                <Icon className="h-4 w-4" />
                {item.name}
              </Link>
            );
          })}
        </nav>
        <div className="space-y-2 border-t border-white/10 p-3">
          <Button variant="ghost" className="w-full justify-start text-emerald-50 hover:bg-white/10 hover:text-white" onClick={() => setDark(!dark)}>
            {dark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
            {dark ? "Açık Mod" : "Koyu Mod"}
          </Button>
          <Button
            variant="ghost"
            className="w-full justify-start text-red-200/90 hover:bg-red-500/20 hover:text-red-100"
            onClick={() => {
              logout();
              router.push("/login");
            }}
          >
            <LogOut className="h-4 w-4" />
            Çıkış Yap
          </Button>
        </div>
      </aside>

      {isSidebarOpen ? <div className="fixed inset-0 z-30 bg-black/40 md:hidden" onClick={() => setSidebarOpen(false)} /> : null}

      <main className="md:pl-72">
        <div className="mx-auto min-h-screen max-w-7xl p-4 sm:p-6 lg:p-8">{children}</div>
      </main>
    </div>
  );
}
