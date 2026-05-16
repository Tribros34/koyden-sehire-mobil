"use client";

import { useQuery } from "@tanstack/react-query";
import { format } from "date-fns";
import { tr } from "date-fns/locale";
import { Eye, Search } from "lucide-react";
import Link from "next/link";
import { useState } from "react";
import { DataTable } from "@/components/admin/DataTable";
import { PageHeader } from "@/components/admin/PageHeader";
import { RiskBadge } from "@/components/admin/RiskBadge";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { adminApi } from "@/lib/api";
import { Application } from "@/lib/types";
import { ColumnDef } from "@tanstack/react-table";

const columns: ColumnDef<Application>[] = [
  {
    accessorKey: "full_name",
    header: "Üretici Adı",
    cell: ({ row }) => (
      <div>
        <p className="font-medium text-stone-900 dark:text-white">{row.original.full_name}</p>
        <p className="text-xs text-stone-500 dark:text-stone-400">{row.original.business_name}</p>
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
    cell: ({ row }) => <StatusBadge status={row.original.status as any} />,
  },
  {
    accessorKey: "risk_level",
    header: "Risk Analizi",
    cell: ({ row }) => <RiskBadge level={row.original.risk_level as any} />,
  },
  {
    accessorKey: "created_at",
    header: "Tarih",
    cell: ({ row }) => (
      <span className="text-sm">
        {format(new Date(row.original.created_at), "d MMM yyyy", { locale: tr })}
      </span>
    ),
  },
  {
    id: "actions",
    cell: ({ row }) => (
      <Button variant="ghost" size="sm" asChild>
        <Link href={`/admin/applications/${row.original.id}`}>
          <Eye className="mr-2 h-4 w-4" />
          İncele
        </Link>
      </Button>
    ),
  },
];

export default function ApplicationsPage() {
  const [searchTerm, setSearchTerm] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["applications"],
    queryFn: () => adminApi.getApplications(),
  });

  const filteredData =
    data?.filter(
      (app) =>
        app.full_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        app.city.toLowerCase().includes(searchTerm.toLowerCase()) ||
        app.invite_code.toLowerCase().includes(searchTerm.toLowerCase())
    ) || [];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Başvurular"
        description="Sisteme kayıt olmak isteyen çiftçi ve üreticilerin listesi."
      />

      <div className="flex items-center gap-4">
        <div className="relative max-w-sm flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-stone-500" />
          <Input
            placeholder="İsim, şehir veya davet kodu ara..."
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
