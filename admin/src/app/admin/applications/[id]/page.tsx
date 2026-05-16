"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { format } from "date-fns";
import { tr } from "date-fns/locale";
import { ArrowLeft, Check, Video, X } from "lucide-react";
import Link from "next/link";
import { use, useState } from "react";
import { PageHeader } from "@/components/admin/PageHeader";
import { RiskBadge } from "@/components/admin/RiskBadge";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ConfirmModal } from "@/components/ui/modal";
import { Input } from "@/components/ui/input";
import { adminApi } from "@/lib/api";

export default function ApplicationDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const resolvedParams = use(params);
  const queryClient = useQueryClient();
  const [rejectModalOpen, setRejectModalOpen] = useState(false);
  const [rejectReason, setRejectReason] = useState("");

  const { data: app, isLoading } = useQuery({
    queryKey: ["application", resolvedParams.id],
    queryFn: () => adminApi.getApplication(resolvedParams.id),
  });

  const reviewMutation = useMutation({
    mutationFn: (args: { action: "approve" | "reject"; reason?: string }) =>
      adminApi.reviewApplication(resolvedParams.id, args.action, args.reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["application", resolvedParams.id] });
      queryClient.invalidateQueries({ queryKey: ["applications"] });
      setRejectModalOpen(false);
      setRejectReason("");
    },
  });

  if (isLoading) {
    return <div className="h-96 animate-pulse rounded-md bg-stone-100 dark:bg-stone-800" />;
  }

  if (!app) return <div>Başvuru bulunamadı.</div>;

  return (
    <div className="space-y-6">
      <div>
        <Button variant="ghost" size="sm" asChild className="mb-4">
          <Link href="/admin/applications">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Başvurulara Dön
          </Link>
        </Button>
        <PageHeader title="Başvuru İncelemesi" description={`${app.full_name} isimli üreticinin başvurusu.`}>
          {app.status === "pending" && (
            <>
              <Button variant="outline" disabled title="Bu özellik için backend endpointi henüz hazır değil.">
                <Video className="mr-2 h-4 w-4" />
                Video İste
              </Button>
              <Button variant="danger" onClick={() => setRejectModalOpen(true)} disabled={reviewMutation.isPending}>
                <X className="mr-2 h-4 w-4" />
                Reddet
              </Button>
              <Button onClick={() => reviewMutation.mutate({ action: "approve" })} disabled={reviewMutation.isPending}>
                <Check className="mr-2 h-4 w-4" />
                Onayla
              </Button>
            </>
          )}
        </PageHeader>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Left Column */}
        <div className="col-span-1 space-y-6 lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Üretici Bilgileri</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <p className="text-sm font-medium text-stone-500">Ad Soyad</p>
                  <p className="font-semibold">{app.full_name}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-stone-500">İşletme Adı</p>
                  <p className="font-semibold">{app.business_name}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-stone-500">Telefon</p>
                  <p>{app.phone}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-stone-500">Lokasyon</p>
                  <p>{app.city}, {app.district}{app.village ? ` - ${app.village}` : ""}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-stone-500">Durum</p>
                  <div className="mt-1"><StatusBadge status={app.status} /></div>
                </div>
                <div>
                  <p className="text-sm font-medium text-stone-500">Başvuru Tarihi</p>
                  <p>{format(new Date(app.created_at), "d MMM yyyy HH:mm", { locale: tr })}</p>
                </div>
              </div>

              {app.profile_description && (
                <div>
                  <p className="text-sm font-medium text-stone-500">Hakkında</p>
                  <p className="mt-1 text-sm">{app.profile_description}</p>
                </div>
              )}

              {app.product_examples && (
                <div>
                  <p className="text-sm font-medium text-stone-500">Ürün Örnekleri</p>
                  <p className="mt-1 text-sm">{app.product_examples}</p>
                </div>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Video Doğrulaması</CardTitle>
            </CardHeader>
            <CardContent>
              {app.video_url ? (
                <div className="aspect-video w-full overflow-hidden rounded-md bg-black">
                  <video src={app.video_url} controls className="h-full w-full object-contain" />
                </div>
              ) : (
                <div className="flex flex-col items-center justify-center rounded-md border border-dashed border-stone-300 p-8 text-center dark:border-stone-700">
                  <Video className="mb-2 h-8 w-8 text-stone-400" />
                  <p className="text-sm font-medium">Video yüklenmemiş</p>
                  <p className="mt-1 text-xs text-stone-500">Bu durum risk skorunu yükseltebilir.</p>
                </div>
              )}
            </CardContent>
          </Card>
        </div>

        {/* Right Column */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Risk Analizi</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {app.risk_level && (
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Genel Risk</span>
                  <RiskBadge level={app.risk_level ?? "low"} />
                </div>
              )}

              <div className="space-y-2 border-t pt-4 dark:border-stone-800">
                {app.invite_code && (
                  <div className="flex items-start justify-between gap-4">
                    <span className="text-sm">Davet Kodu</span>
                    <span className={`text-sm font-medium ${app.invite_trust === "trusted" ? "text-emerald-600" : "text-amber-600"}`}>
                      {app.invite_code}{app.invite_trust ? ` (${app.invite_trust})` : ""}
                    </span>
                  </div>
                )}
                <div className="flex items-start justify-between gap-4">
                  <span className="text-sm">Video Durumu</span>
                  <span className={`text-sm font-medium ${app.video_url ? "text-emerald-600" : "text-red-600"}`}>
                    {app.video_url ? "Yüklendi" : "Eksik"}
                  </span>
                </div>
                {app.profile_description && (
                  <div className="flex items-start justify-between gap-4">
                    <span className="text-sm">Profil Doluluğu</span>
                    <span className={`text-sm font-medium ${app.profile_description.length > 20 ? "text-emerald-600" : "text-red-600"}`}>
                      {app.profile_description.length > 20 ? "Yeterli" : "Kısa"}
                    </span>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Admin Notları</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-stone-600 dark:text-stone-400">
                {app.admin_notes ?? "Henüz not eklenmemiş."}
              </p>
            </CardContent>
          </Card>
        </div>
      </div>

      <ConfirmModal
        open={rejectModalOpen}
        onOpenChange={setRejectModalOpen}
        title="Başvuruyu Reddet"
        description="Lütfen reddetme sebebini yazın. Bu bilgi SMS ile üreticiye iletilecektir."
        confirmLabel="Reddet"
        danger
        onConfirm={() => {
          if (!rejectReason) return;
          reviewMutation.mutate({ action: "reject", reason: rejectReason });
        }}
      >
        <Input
          placeholder="Reddetme sebebi..."
          value={rejectReason}
          onChange={(e) => setRejectReason(e.target.value)}
        />
      </ConfirmModal>
    </div>
  );
}
