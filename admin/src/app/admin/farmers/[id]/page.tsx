"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ArrowLeft, Check, ShieldCheck, Ban, ShieldAlert, Edit2 } from "lucide-react";
import Link from "next/link";
import { use, useState } from "react";
import { PageHeader } from "@/components/admin/PageHeader";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ConfirmModal } from "@/components/ui/modal";
import { Input } from "@/components/ui/input";
import { adminApi } from "@/lib/api";

export default function FarmerDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const resolvedParams = use(params);
  const queryClient = useQueryClient();
  const [suspendModalOpen, setSuspendModalOpen] = useState(false);
  const [quotaModalOpen, setQuotaModalOpen] = useState(false);
  const [newQuota, setNewQuota] = useState("");

  const { data: farmer, isLoading } = useQuery({
    queryKey: ["farmer", resolvedParams.id],
    queryFn: () => adminApi.getFarmer(resolvedParams.id),
  });

  const updateMutation = useMutation({
    mutationFn: (payload: any) => adminApi.updateFarmer(resolvedParams.id, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["farmer", resolvedParams.id] });
      queryClient.invalidateQueries({ queryKey: ["farmers"] });
      setSuspendModalOpen(false);
      setQuotaModalOpen(false);
    },
  });

  if (isLoading) {
    return <div className="h-96 animate-pulse rounded-md bg-stone-100 dark:bg-stone-800" />;
  }

  if (!farmer) return <div>Çiftçi bulunamadı.</div>;

  return (
    <div className="space-y-6">
      <div>
        <Button variant="ghost" size="sm" asChild className="mb-4">
          <Link href="/admin/farmers">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Çiftçilere Dön
          </Link>
        </Button>
        <PageHeader title="Çiftçi Profili" description={`${farmer.full_name} isimli üreticinin detayları.`}>
          {farmer.status === "active" ? (
            <Button variant="danger" onClick={() => setSuspendModalOpen(true)} disabled={updateMutation.isPending}>
              <Ban className="mr-2 h-4 w-4" />
              Askıya Al
            </Button>
          ) : (
            <Button onClick={() => updateMutation.mutate({ status: "active" })} disabled={updateMutation.isPending}>
              <Check className="mr-2 h-4 w-4" />
              Aktifleştir
            </Button>
          )}
        </PageHeader>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Left Column */}
        <div className="col-span-1 space-y-6 lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Kişisel Bilgiler</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <p className="text-sm font-medium text-stone-500">Ad Soyad</p>
                  <p className="font-semibold flex items-center gap-2">
                    {farmer.full_name}
                    {farmer.is_founding_farmer && <ShieldCheck className="h-4 w-4 text-emerald-600" title="Kurucu Çiftçi" />}
                  </p>
                </div>
                <div>
                  <p className="text-sm font-medium text-stone-500">Telefon</p>
                  <p>{farmer.phone}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-stone-500">Lokasyon</p>
                  <p>{farmer.city}, {farmer.district}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-stone-500">Durum</p>
                  <div className="mt-1"><StatusBadge status={farmer.status as any} /></div>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t dark:border-stone-800">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-stone-500">Davet Kodu</p>
                    <p className="font-mono mt-1 font-semibold text-lg">{farmer.invite_code}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-medium text-stone-500">Kalan Kota / Toplam</p>
                    <p className="font-medium">{farmer.invite_quota} adet</p>
                    <Button variant="link" size="sm" className="px-0 h-auto text-emerald-600" onClick={() => {
                      setNewQuota(farmer.invite_quota.toString());
                      setQuotaModalOpen(true);
                    }}>
                      <Edit2 className="h-3 w-3 mr-1" />
                      Kotayı Düzenle
                    </Button>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
          
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle className="text-lg">Kurucu Çiftçi Yetkisi</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium">Bu üretici kurucu çiftçi mi?</p>
                  <p className="text-sm text-stone-500">Kurucu çiftçiler sınırsız davet edebilir ve ağın kökü olurlar.</p>
                </div>
                <Button 
                  variant={farmer.is_founding_farmer ? "outline" : "default"}
                  onClick={() => updateMutation.mutate({ is_founding_farmer: !farmer.is_founding_farmer })}
                  disabled={updateMutation.isPending}
                >
                  {farmer.is_founding_farmer ? "Yetkiyi Al" : "Kurucu Yap"}
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Right Column */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Güven Skoru Analizi</CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="flex flex-col items-center justify-center py-4">
                <div className={`flex h-24 w-24 items-center justify-center rounded-full border-4 ${
                  farmer.trust_score >= 80 ? "border-emerald-500 text-emerald-600" :
                  farmer.trust_score >= 50 ? "border-amber-500 text-amber-600" :
                  "border-red-500 text-red-600"
                }`}>
                  <span className="text-3xl font-bold">{farmer.trust_score}</span>
                </div>
                <p className="mt-2 text-sm font-medium text-stone-500">100 Üzerinden</p>
              </div>

              <div className="space-y-3 border-t pt-4 dark:border-stone-800">
                <div className="flex items-center justify-between text-sm">
                  <span className="flex items-center gap-2"><Check className="h-4 w-4 text-emerald-500"/> Profil Doluluğu</span>
                  <span className="font-medium">{farmer.profile_completion}%</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="flex items-center gap-2">
                    {farmer.video_verified ? <Check className="h-4 w-4 text-emerald-500"/> : <ShieldAlert className="h-4 w-4 text-amber-500"/>}
                    Video Doğrulaması
                  </span>
                  <span className="font-medium">{farmer.video_verified ? "Evet" : "Hayır"}</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="flex items-center gap-2"><Check className="h-4 w-4 text-emerald-500"/> Onaylı Ürün</span>
                  <span className="font-medium">{farmer.approved_products} / {farmer.products_count}</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="flex items-center gap-2">
                    {farmer.complaints_count === 0 ? <Check className="h-4 w-4 text-emerald-500"/> : <ShieldAlert className="h-4 w-4 text-red-500"/>} 
                    Şikayetler
                  </span>
                  <span className={`font-medium ${farmer.complaints_count > 0 ? "text-red-600" : ""}`}>{farmer.complaints_count}</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="flex items-center gap-2"><Check className="h-4 w-4 text-emerald-500"/> Başarılı Davet</span>
                  <span className="font-medium">{farmer.invite_history} kişi</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      <ConfirmModal
        open={suspendModalOpen}
        onOpenChange={setSuspendModalOpen}
        title="Hesabı Askıya Al"
        description="Üreticinin hesabı askıya alınacak ve ürünleri gizlenecektir. Onaylıyor musunuz?"
        confirmLabel="Askıya Al"
        danger
        onConfirm={() => updateMutation.mutate({ status: "suspended" })}
      />

      <ConfirmModal
        open={quotaModalOpen}
        onOpenChange={setQuotaModalOpen}
        title="Davet Kotasını Güncelle"
        description="Üreticinin sisteme davet edebileceği kişi sayısını belirleyin."
        confirmLabel="Güncelle"
        onConfirm={() => {
          const quota = parseInt(newQuota);
          if (isNaN(quota)) return;
          updateMutation.mutate({ invite_quota: quota });
        }}
      >
        <Input
          type="number"
          placeholder="Yeni kota..."
          value={newQuota}
          onChange={(e) => setNewQuota(e.target.value)}
        />
      </ConfirmModal>
    </div>
  );
}
