"use client";

import { useQuery } from "@tanstack/react-query";
import { Eye, Search, ShieldCheck } from "lucide-react";
import Link from "next/link";
import { useState } from "react";
import { DataTable } from "@/components/admin/DataTable";
import { PageHeader } from "@/components/admin/PageHeader";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { adminApi } from "@/lib/api";
import { Farmer } from "@/lib/types";
import { ColumnDef } from "@tanstack/react-table";

const columns: ColumnDef<Farmer>[] = [
  {
    accessorKey: "full_name",
    header: "Çiftçi",
    cell: ({ row }) => (
      <div>
        <p className="font-medium text-stone-900 dark:text-white flex items-center gap-1.5">
          {row.original.full_name}
          {row.original.is_founding_farmer && (
            <span title="Kurucu Çiftçi"><ShieldCheck className="h-4 w-4 text-emerald-600" /></span>
          )}
        </p>
        <p className="text-xs text-stone-500">{row.original.phone}</p>
      </div>
    ),
  },
  {
    accessorKey: "city",
    header: "Lokasyon",
    cell: ({ row }) => (
      <span className="text-sm">
        {row.original.city}, {row.original.district}
      </span>
    ),
  },
  {
    accessorKey: "status",
    header: "Durum",
    cell: ({ row }) => <StatusBadge status={row.original.status} />,
  },
  {
    accessorKey: "trust_score",
    header: "Güven Skoru",
    cell: ({ row }) => {
      const score = row.original.trust_score;
      let colorClass = "text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20";
      if (score < 50) colorClass = "text-red-600 bg-red-50 dark:bg-red-900/20";
      else if (score < 80) colorClass = "text-amber-600 bg-amber-50 dark:bg-amber-900/20";

      return (
        <span className={`inline-flex items-center justify-center rounded-md px-2 py-1 text-sm font-bold ${colorClass}`}>
          {score}
        </span>
      );
    },
  },
  {
    accessorKey: "products_count",
    header: "Ürünler",
    cell: ({ row }) => <span className="text-sm">{row.original.products_count} adet</span>,
  },
  {
    id: "actions",
    cell: ({ row }) => (
      <Button variant="ghost" size="sm" asChild>
        <Link href={`/admin/farmers/${row.original.id}`}>
          <Eye className="mr-2 h-4 w-4" />
          İncele
        </Link>
      </Button>
    ),
  },
];

export default function FarmersPage() {
  const [searchTerm, setSearchTerm] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["farmers"],
    queryFn: () => adminApi.getFarmers(),
  });

  const filteredData =
    data?.filter(
      (farmer: Farmer) =>
        farmer.full_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        farmer.city.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (farmer.invite_code ?? "").toLowerCase().includes(searchTerm.toLowerCase())
    ) || [];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Çiftçiler"
        description="Sistemdeki tüm kayıtlı üreticiler ve güven skorları."
      />

      <div className="flex items-center gap-4">
        <div className="relative max-w-sm flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-stone-500" />
          <Input
            placeholder="İsim, şehir veya kod ara..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-9"
          />
        </div>
      </div>

      {isLoading ? (
        <div className="h-64 animate-pulse rounded-md border border-stone-200 bg-stone-50 dark:border-stone-800 dark:bg-stone-900/50" />
      ) : (
        <DataTable columns={columns} data={filteredData} />
      )}
    </div>
  );
}
