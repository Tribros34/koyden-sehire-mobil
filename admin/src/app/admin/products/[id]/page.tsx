"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ArrowLeft, Check, X, AlertTriangle } from "lucide-react";
import Link from "next/link";
import { use, useState } from "react";
import { PageHeader } from "@/components/admin/PageHeader";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ConfirmModal } from "@/components/ui/modal";
import { Input } from "@/components/ui/input";
import { adminApi } from "@/lib/api";

const CHECKLIST_ITEMS = [
  { id: "title", label: "Ürün adı açık ve anlaşılır mı?" },
  { id: "image", label: "Görsel ürünle uyuşuyor ve net mi?" },
  { id: "price", label: "Fiyat piyasa koşullarına uygun mu?" },
  { id: "category", label: "Kategori doğru seçilmiş mi?" },
  { id: "content", label: "Açıklamada yasaklı ifade var mı? (Yoksa işaretle)" },
];

export default function ProductDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const resolvedParams = use(params);
  const queryClient = useQueryClient();
  const [rejectModalOpen, setRejectModalOpen] = useState(false);
  const [rejectReason, setRejectReason] = useState("");
  const [checkedItems, setCheckedItems] = useState<Record<string, boolean>>({});

  const { data: product, isLoading } = useQuery({
    queryKey: ["product", resolvedParams.id],
    queryFn: () => adminApi.getProduct(resolvedParams.id),
  });

  const reviewMutation = useMutation({
    mutationFn: (args: { action: "active" | "rejected" | "hidden"; reason?: string }) =>
      adminApi.moderateProduct(resolvedParams.id, args.action, args.reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["product", resolvedParams.id] });
      queryClient.invalidateQueries({ queryKey: ["products"] });
      setRejectModalOpen(false);
      setRejectReason("");
    },
  });

  const isChecklistComplete = CHECKLIST_ITEMS.every((item) => checkedItems[item.id]);

  if (isLoading) {
    return <div className="h-96 animate-pulse rounded-md bg-stone-100 dark:bg-stone-800" />;
  }

  if (!product) return <div>Ürün bulunamadı.</div>;

  return (
    <div className="space-y-6">
      <div>
        <Button variant="ghost" size="sm" asChild className="mb-4">
          <Link href="/admin/products">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Ürünlere Dön
          </Link>
        </Button>
        <PageHeader title="Ürün Moderasyonu" description={`Üretici: ${product.farmer_name}`}>
          {product.status === "pending" && (
            <>
              <Button variant="danger" onClick={() => setRejectModalOpen(true)} disabled={reviewMutation.isPending}>
                <X className="mr-2 h-4 w-4" />
                Reddet
              </Button>
              <Button
                onClick={() => reviewMutation.mutate({ action: "active" })}
                disabled={reviewMutation.isPending || !isChecklistComplete}
                title={!isChecklistComplete ? "Önce kalite kontrol listesini tamamlayın" : ""}
              >
                <Check className="mr-2 h-4 w-4" />
                Onayla
              </Button>
            </>
          )}
          {product.status === "active" && (
            <Button variant="outline" onClick={() => reviewMutation.mutate({ action: "hidden" })} disabled={reviewMutation.isPending}>
              <AlertTriangle className="mr-2 h-4 w-4" />
              Askıya Al / Gizle
            </Button>
          )}
        </PageHeader>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Left Column */}
        <div className="col-span-1 space-y-6 lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Ürün Detayları</CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="flex flex-col gap-6 sm:flex-row">
                <div className="h-48 w-48 flex-shrink-0 overflow-hidden rounded-lg bg-stone-100">
                  <img src={product.image_urls[0]} alt={product.title} className="h-full w-full object-cover" />
                </div>
                <div className="flex-1 space-y-4">
                  <div>
                    <h2 className="text-xl font-bold">{product.title}</h2>
                    <p className="text-sm text-stone-500">{product.category_name}</p>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    <StatusBadge status={product.status as any} />
                    {product.moderation_tags?.map((tag) => (
                      <span key={tag} className="inline-flex items-center rounded-md bg-stone-100 px-2 py-0.5 text-xs font-medium text-stone-600 dark:bg-stone-800 dark:text-stone-300">
                        {tag}
                      </span>
                    ))}
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <p className="text-sm font-medium text-stone-500">Fiyat</p>
                      <p className="font-semibold text-lg">{product.price} ₺ <span className="text-sm font-normal text-stone-500">/ {product.unit}</span></p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-stone-500">Stok</p>
                      <p className="font-semibold">{product.stock} adet</p>
                    </div>
                  </div>
                </div>
              </div>

              <div>
                <p className="text-sm font-medium text-stone-500">Açıklama</p>
                <p className="mt-2 text-sm leading-relaxed">{product.description}</p>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Right Column */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Kalite Kontrol Checklist</CardTitle>
            </CardHeader>
            <CardContent>
              {product.status === "pending" ? (
                <div className="space-y-3">
                  {CHECKLIST_ITEMS.map((item) => (
                    <label key={item.id} className="flex items-start gap-3 rounded-md border border-stone-200 p-3 hover:bg-stone-50 dark:border-stone-800 dark:hover:bg-stone-900/50 cursor-pointer">
                      <input
                        type="checkbox"
                        className="mt-1 h-4 w-4 rounded border-stone-300 text-emerald-600 focus:ring-emerald-600"
                        checked={!!checkedItems[item.id]}
                        onChange={(e) => setCheckedItems({ ...checkedItems, [item.id]: e.target.checked })}
                      />
                      <span className="text-sm leading-tight text-stone-700 dark:text-stone-300">{item.label}</span>
                    </label>
                  ))}
                  
                  {!isChecklistComplete && (
                    <p className="text-xs text-amber-600 dark:text-amber-400 mt-4 text-center">
                      Onaylayabilmek için tüm maddeleri işaretlemelisiniz.
                    </p>
                  )}
                </div>
              ) : (
                <div className="flex items-center gap-2 text-sm text-emerald-600 dark:text-emerald-400">
                  <Check className="h-4 w-4" />
                  Bu ürün moderasyondan geçmiş.
                </div>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Üretici Özeti</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
               <div>
                  <p className="text-sm font-medium text-stone-500">İsim</p>
                  <Link href={`/admin/farmers/${product.farmer_id}`} className="font-semibold text-emerald-700 hover:underline dark:text-emerald-500">
                    {product.farmer_name}
                  </Link>
                </div>
                <div>
                  <p className="text-sm font-medium text-stone-500">Lokasyon</p>
                  <p className="text-sm">{product.city}</p>
                </div>
            </CardContent>
          </Card>
        </div>
      </div>

      <ConfirmModal
        open={rejectModalOpen}
        onOpenChange={setRejectModalOpen}
        title="Ürünü Reddet"
        description="Lütfen reddetme sebebini yazın. Bu bilgi SMS ile üreticiye iletilecektir ve ürünü düzenlemesi istenecektir."
        confirmLabel="Reddet"
        danger
        onConfirm={() => {
          if (!rejectReason) return;
          reviewMutation.mutate({ action: "rejected", reason: rejectReason });
        }}
      >
        <Input
          placeholder="Örn: Görsel çok bulanık..."
          value={rejectReason}
          onChange={(e) => setRejectReason(e.target.value)}
        />
      </ConfirmModal>
    </div>
  );
}
