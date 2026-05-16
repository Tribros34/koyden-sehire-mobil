"use client";

import { useQuery } from "@tanstack/react-query";
import { ChevronDown, ChevronRight, Edit2, Plus, Trash2 } from "lucide-react";
import { useState } from "react";
import { PageHeader } from "@/components/admin/PageHeader";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { adminApi } from "@/lib/api";
import { Category } from "@/lib/types";

export default function CategoriesPage() {
  const { data: categories, isLoading } = useQuery({
    queryKey: ["categories"],
    queryFn: () => adminApi.getCategories(),
  });

  if (isLoading) {
    return (
      <div className="space-y-6">
        <PageHeader title="Kategoriler" />
        <div className="h-64 animate-pulse rounded-md bg-stone-100 dark:bg-stone-800" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title="Kategori Yönetimi"
        description="Platformdaki ürün kategorileri ve hiyerarşisi."
      >
        <Button>
          <Plus className="mr-2 h-4 w-4" />
          Yeni Kategori
        </Button>
      </PageHeader>

      <Card>
        <CardContent className="p-6">
          <div className="space-y-2">
            {categories?.map((category) => (
              <CategoryNode key={category.id} category={category} level={0} />
            ))}
            {!categories?.length && (
              <p className="text-sm text-stone-500">Henüz kategori bulunmuyor.</p>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

function CategoryNode({ category, level }: { category: Category; level: number }) {
  const [isExpanded, setIsExpanded] = useState(true);
  const hasChildren = category.children && category.children.length > 0;

  return (
    <div className="flex flex-col gap-2">
      <div
        className={`flex items-center justify-between rounded-md border border-stone-200 bg-white p-3 hover:bg-stone-50 dark:border-stone-800 dark:bg-stone-950 dark:hover:bg-stone-900/50 ${
          level > 0 ? "ml-8" : ""
        }`}
      >
        <div className="flex items-center gap-3">
          <Button
            variant="ghost"
            size="sm"
            className="h-6 w-6 p-0"
            onClick={() => setIsExpanded(!isExpanded)}
            disabled={!hasChildren}
          >
            {hasChildren ? (
              isExpanded ? (
                <ChevronDown className="h-4 w-4" />
              ) : (
                <ChevronRight className="h-4 w-4" />
              )
            ) : (
              <div className="h-4 w-4" />
            )}
          </Button>
          <span className="font-medium text-stone-900 dark:text-white">
            {category.name}
          </span>
          {!category.active && (
            <span className="rounded bg-stone-100 px-1.5 py-0.5 text-xs text-stone-500 dark:bg-stone-800">
              Pasif
            </span>
          )}
        </div>
        
        <div className="flex items-center gap-2">
          <Button variant="ghost" size="sm" className="h-8 w-8 p-0" title="Alt Kategori Ekle">
            <Plus className="h-4 w-4" />
          </Button>
          <Button variant="ghost" size="sm" className="h-8 w-8 p-0" title="Düzenle">
            <Edit2 className="h-4 w-4 text-stone-500" />
          </Button>
          <Button variant="ghost" size="sm" className="h-8 w-8 p-0 hover:text-red-600" title="Sil">
            <Trash2 className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {isExpanded && hasChildren && (
        <div className="flex flex-col gap-2">
          {category.children!.map((child) => (
            <CategoryNode key={child.id} category={child} level={level + 1} />
          ))}
        </div>
      )}
    </div>
  );
}
