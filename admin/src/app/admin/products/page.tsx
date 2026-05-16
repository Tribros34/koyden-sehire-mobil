"use client";

import { useQuery } from "@tanstack/react-query";
import { format } from "date-fns";
import { tr } from "date-fns/locale";
import { Eye, Search } from "lucide-react";
import Link from "next/link";
import { useState } from "react";
import { DataTable } from "@/components/admin/DataTable";
import { PageHeader } from "@/components/admin/PageHeader";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { adminApi } from "@/lib/api";
import { Product } from "@/lib/types";
import { ColumnDef } from "@tanstack/react-table";

const columns: ColumnDef<Product>[] = [
  {
    accessorKey: "title",
    header: "Ürün",
    cell: ({ row }) => {
      const imageUrl = row.original.images?.[0]?.url;
      return (
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 flex-shrink-0 overflow-hidden rounded-md bg-stone-100">
            {imageUrl ? (
              <img src={imageUrl} alt={row.original.title} className="h-full w-full object-cover" />
            ) : (
              <div className="h-full w-full bg-stone-200" />
            )}
          </div>
          <div>
            <p className="font-medium text-stone-900 dark:text-white">{row.original.title}</p>
            <p className="text-xs text-stone-500">{row.original.category?.name ?? "—"}</p>
          </div>
        </div>
      );
    },
  },
  {
    id: "farmer_name",
    header: "Üretici",
    cell: ({ row }) => (
      <span className="text-sm">{row.original.farmer?.display_name ?? "—"}</span>
    ),
  },
  {
    accessorKey: "price",
    header: "Fiyat",
    cell: ({ row }) => (
      <span className="text-sm font-medium">
        {row.original.price} ₺{" "}
        <span className="text-xs font-normal text-stone-500">/ {row.original.unit}</span>
      </span>
    ),
  },
  {
    accessorKey: "status",
    header: "Durum",
    cell: ({ row }) => <StatusBadge status={row.original.status} />,
  },
  {
    id: "actions",
    cell: ({ row }) => (
      <Button variant="ghost" size="sm" asChild>
        <Link href={`/admin/products/${row.original.id}`}>
          <Eye className="mr-2 h-4 w-4" />
          İncele
        </Link>
      </Button>
    ),
  },
];

export default function ProductsPage() {
  const [searchTerm, setSearchTerm] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["products"],
    queryFn: () => adminApi.getProducts(),
  });

  const filteredData =
    data?.filter(
      (product) =>
        product.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (product.farmer?.display_name ?? "").toLowerCase().includes(searchTerm.toLowerCase()) ||
        (product.category?.name ?? "").toLowerCase().includes(searchTerm.toLowerCase())
    ) || [];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Ürün Moderasyonu"
        description="Sisteme eklenen ürünlerin incelenmesi ve onaylanması."
      />

      <div className="flex items-center gap-4">
        <div className="relative max-w-sm flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-stone-500" />
          <Input
            placeholder="Ürün, üretici veya kategori ara..."
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
