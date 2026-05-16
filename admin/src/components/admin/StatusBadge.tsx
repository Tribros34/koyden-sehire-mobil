import { cn } from "@/lib/utils";
import { CheckCircle2, AlertCircle, Clock, EyeOff } from "lucide-react";

type StatusType = "pending" | "approved" | "rejected" | "hidden" | "active" | "suspended" | "passive" | "needs_video" | string;

export function StatusBadge({ status, className }: { status: StatusType; className?: string }) {
  let colorClass = "";
  let label = "";
  let Icon = Clock;

  switch (status) {
    case "approved":
    case "active":
      colorClass = "bg-emerald-100 text-emerald-800 border-emerald-200 dark:bg-emerald-900/30 dark:text-emerald-400 dark:border-emerald-800";
      label = status === "active" ? "Aktif" : "Onaylandı";
      Icon = CheckCircle2;
      break;
    case "rejected":
    case "suspended":
      colorClass = "bg-red-100 text-red-800 border-red-200 dark:bg-red-900/30 dark:text-red-400 dark:border-red-800";
      label = status === "suspended" ? "Askıda" : "Reddedildi";
      Icon = AlertCircle;
      break;
    case "hidden":
      colorClass = "bg-stone-100 text-stone-800 border-stone-200 dark:bg-stone-800 dark:text-stone-400 dark:border-stone-700";
      label = "Gizlendi";
      Icon = EyeOff;
      break;
    case "pending":
    default:
      colorClass = "bg-amber-100 text-amber-800 border-amber-200 dark:bg-amber-900/30 dark:text-amber-400 dark:border-amber-800";
      label = "Bekliyor";
      Icon = Clock;
      break;
  }

  return (
    <div className={cn("inline-flex items-center gap-1.5 rounded-full border px-2.5 py-0.5 text-xs font-semibold", colorClass, className)}>
      <Icon className="h-3.5 w-3.5" />
      {label}
    </div>
  );
}
