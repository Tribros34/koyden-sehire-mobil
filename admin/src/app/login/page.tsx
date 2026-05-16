"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { ArrowRight, ShieldCheck } from "lucide-react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { adminApi } from "@/lib/api";
import { useAuthStore } from "@/lib/store";

const schema = z.object({
  phone: z.string().min(10, "Telefon numarası gerekli"),
  password: z.string().min(4, "Şifre gerekli"),
});

type LoginValues = z.infer<typeof schema>;

export default function LoginPage() {
  const router = useRouter();
  const setToken = useAuthStore((state) => state.setToken);
  const {
    register,
    handleSubmit,
    setError,
    formState: { errors, isSubmitting },
  } = useForm<LoginValues>({
    resolver: zodResolver(schema),
    defaultValues: { phone: "05000000000", password: "admin123" },
  });

  const onSubmit = async (values: LoginValues) => {
    try {
      const res = await adminApi.login(values.phone, values.password);
      setToken(res.token);
      router.push("/admin/dashboard");
    } catch (error) {
      setError("root", { message: error instanceof Error ? error.message : "Giriş başarısız" });
    }
  };

  return (
    <main className="min-h-screen bg-stone-50 p-4 text-stone-950 dark:bg-stone-950 dark:text-stone-50 transition-colors duration-300">
      <div className="mx-auto flex min-h-screen max-w-6xl items-center justify-center">
        <div className="grid w-full gap-8 lg:grid-cols-[1fr_440px] lg:items-center">
          <section className="hidden lg:block">
            <div className="max-w-xl">
              <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-emerald-200 bg-white px-3 py-1 text-sm font-medium text-emerald-800 shadow-sm dark:border-emerald-800/50 dark:bg-emerald-950/30 dark:text-emerald-400">
                <ShieldCheck className="h-4 w-4" />
                Güven ve kalite operasyon merkezi
              </div>
              <h1 className="text-5xl font-bold tracking-tight text-stone-950 dark:text-white">
                Köyden Şehire Admin Paneli
              </h1>
              <p className="mt-5 text-lg leading-8 text-stone-600 dark:text-stone-400">
                Başvuru riski, üretici güveni, ürün moderasyonu, davet ağı ve platform sağlığını tek ekranda yönetin.
              </p>
            </div>
          </section>

          <Card className="border-stone-200 bg-white shadow-xl dark:border-stone-800 dark:bg-stone-900 overflow-hidden relative">
            <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/5 via-transparent to-transparent pointer-events-none" />
            <CardContent className="p-6 sm:p-8 relative z-10">
              <div className="mb-8">
                <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-600 to-emerald-800 text-white shadow-md">
                  <ShieldCheck className="h-6 w-6" />
                </div>
                <h2 className="text-2xl font-bold dark:text-white">Yönetici Girişi</h2>
                <p className="mt-1 text-sm text-stone-500 dark:text-stone-400">Sisteme girmek için bilgilerinizi yazın.</p>
              </div>

              {errors.root?.message ? (
                <div className="mb-4 rounded-md border border-red-200 bg-red-50 p-3 text-sm text-red-700">
                  {errors.root.message}
                </div>
              ) : null}

              <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
                <div>
                  <label className="mb-1.5 block text-sm font-medium dark:text-stone-300">Telefon</label>
                  <Input className="dark:bg-stone-950 dark:border-stone-800" placeholder="05xxxxxxxxx" {...register("phone")} />
                  {errors.phone ? <p className="mt-1.5 text-xs text-red-600 dark:text-red-400">{errors.phone.message}</p> : null}
                </div>
                <div>
                  <label className="mb-1.5 block text-sm font-medium dark:text-stone-300">Şifre</label>
                  <Input className="dark:bg-stone-950 dark:border-stone-800" type="password" {...register("password")} />
                  {errors.password ? <p className="mt-1.5 text-xs text-red-600 dark:text-red-400">{errors.password.message}</p> : null}
                </div>
                <Button className="w-full h-11 bg-emerald-700 hover:bg-emerald-800 text-white transition-all shadow-md hover:shadow-lg dark:bg-emerald-600 dark:hover:bg-emerald-700" type="submit" disabled={isSubmitting}>
                  {isSubmitting ? "Giriş yapılıyor..." : "Panele Gir"}
                  <ArrowRight className="h-4 w-4" />
                </Button>
              </form>
            </CardContent>
          </Card>
        </div>
      </div>
    </main>
  );
}
