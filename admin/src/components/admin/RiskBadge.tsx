import { cn } from "@/lib/utils";
import { ShieldAlert, ShieldCheck, Shield } from "lucide-react";

type RiskLevel = "low" | "medium" | "high";

export function RiskBadge({ level, className }: { level: RiskLevel; className?: string }) {
  let colorClass = "";
  let label = "";
  let Icon = Shield;

  switch (level) {
    case "low":
      colorClass = "bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-900/20 dark:text-emerald-400 dark:border-emerald-800/50";
      label = "Düşük Risk";
      Icon = ShieldCheck;
      break;
    case "high":
      colorClass = "bg-red-50 text-red-700 border-red-200 dark:bg-red-900/20 dark:text-red-400 dark:border-red-800/50";
      label = "Yüksek Risk";
      Icon = ShieldAlert;
      break;
    case "medium":
    default:
      colorClass = "bg-amber-50 text-amber-700 border-amber-200 dark:bg-amber-900/20 dark:text-amber-400 dark:border-amber-800/50";
      label = "Orta Risk";
      Icon = Shield;
      break;
  }

  return (
    <div className={cn("inline-flex items-center gap-1.5 rounded-md border px-2 py-0.5 text-xs font-medium shadow-sm", colorClass, className)}>
      <Icon className="h-3.5 w-3.5" />
      {label}
    </div>
  );
}
