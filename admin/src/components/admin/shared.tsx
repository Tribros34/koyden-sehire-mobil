import Link from "next/link";
import { ReactNode } from "react";
import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import { ApplicationStatus, ProductStatus, RiskLevel } from "@/lib/types";
import { cn } from "@/lib/utils";

export function PageHeader({
  title,
  description,
  action,
}: {
  title: string;
  description?: string;
  action?: ReactNode;
}) {
  return (
    <div className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-stone-950 dark:text-stone-50">{title}</h1>
        {description ? <p className="mt-1 text-sm text-stone-500">{description}</p> : null}
      </div>
      {action}
    </div>
  );
}

export function LoadingSkeleton() {
  return (
    <div className="space-y-4">
      <div className="h-8 w-64 animate-pulse rounded bg-stone-200" />
      <div className="grid gap-4 md:grid-cols-3">
        {[1, 2, 3, 4, 5, 6].map((item) => (
          <div key={item} className="h-28 animate-pulse rounded-lg bg-stone-200" />
        ))}
      </div>
    </div>
  );
}

export function EmptyState({ title, description }: { title: string; description: string }) {
  return (
    <Card className="flex min-h-52 items-center justify-center p-8 text-center">
      <div>
        <h3 className="font-semibold">{title}</h3>
        <p className="mt-1 text-sm text-stone-500">{description}</p>
      </div>
    </Card>
  );
}

export function StatusBadge({ status }: { status: ApplicationStatus | ProductStatus | string }) {
  const tone =
    status === "approved" || status === "active"
      ? "green"
      : status === "pending" || status === "needs_video"
        ? "amber"
        : status === "rejected"
          ? "red"
          : "stone";
  return <Badge tone={tone}>{status}</Badge>;
}

export function RiskBadge({ risk }: { risk: RiskLevel }) {
  const tone = risk === "low" ? "green" : risk === "medium" ? "amber" : "red";
  return <Badge tone={tone}>{risk}</Badge>;
}

export function AdminTable({
  columns,
  rows,
}: {
  columns: string[];
  rows: ReactNode[][];
}) {
  return (
    <div className="overflow-hidden rounded-lg border border-stone-200 bg-white text-stone-950">
      <div className="overflow-x-auto">
        <table className="w-full min-w-[760px] text-sm">
          <thead className="bg-stone-50 text-left text-xs uppercase tracking-wide text-stone-600">
            <tr>
              {columns.map((column) => (
                <th key={column} className="px-4 py-3 font-semibold">
                  {column}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-stone-100">
            {rows.map((row, index) => (
              <tr key={index} className="hover:bg-stone-50/70">
                {row.map((cell, cellIndex) => (
                  <td key={cellIndex} className="px-4 py-3 align-middle">
                    {cell}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export function DetailLink({ href, children }: { href: string; children: ReactNode }) {
  return (
    <Link className="font-medium text-emerald-700 hover:text-emerald-900" href={href}>
      {children}
    </Link>
  );
}

export function SelectFilter({
  value,
  onChange,
  options,
  className,
}: {
  value: string;
  onChange: (value: string) => void;
  options: { value: string; label: string }[];
  className?: string;
}) {
  return (
    <select
      value={value}
      onChange={(event) => onChange(event.target.value)}
      className={cn(
        "h-10 rounded-md border border-stone-200 bg-white px-3 text-sm text-stone-950",
        className,
      )}
    >
      {options.map((option) => (
        <option key={option.value} value={option.value}>
          {option.label}
        </option>
      ))}
    </select>
  );
}
