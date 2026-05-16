"use client";

import { useQuery } from "@tanstack/react-query";
import { AlertCircle, Clock, MapPin, Search, Users } from "lucide-react";
import { useState } from "react";
import { PageHeader } from "@/components/admin/PageHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { adminApi } from "@/lib/api";

export default function MapPage() {
  const [searchTerm, setSearchTerm] = useState("");

  const { data: cityDensity, isLoading } = useQuery({
    queryKey: ["cityDensity"],
    queryFn: () => adminApi.getCityDensity(),
  });

  const filteredData = cityDensity?.filter(item => 
    item.city.toLowerCase().includes(searchTerm.toLowerCase())
  ) || [];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Bölgesel Yoğunluk"
        description="Şehir bazlı üretici sayısı, bekleyen başvurular ve risk durumu."
      />

      <div className="flex items-center gap-4">
        <div className="relative max-w-sm flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-stone-500" />
          <Input
            placeholder="Şehir ara..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-9"
          />
        </div>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="h-40 animate-pulse rounded-md bg-stone-100 dark:bg-stone-800" />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {filteredData.map((item) => (
            <CityCard key={item.city} data={item} />
          ))}
          {filteredData.length === 0 && (
            <div className="col-span-full py-12 text-center text-stone-500">
              Sonuç bulunamadı.
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function CityCard({ data }: { data: any }) {
  let borderClass = "border-stone-200 dark:border-stone-800";
  let bgClass = "";
  
  if (data.risk === "high") {
    borderClass = "border-red-200 dark:border-red-900/50";
    bgClass = "bg-red-50/50 dark:bg-red-900/10";
  } else if (data.risk === "medium") {
    borderClass = "border-amber-200 dark:border-amber-900/50";
    bgClass = "bg-amber-50/50 dark:bg-amber-900/10";
  }

  return (
    <Card className={`${borderClass} ${bgClass} transition-all hover:shadow-md`}>
      <CardHeader className="pb-2">
        <CardTitle className="flex items-center gap-2 text-lg">
          <MapPin className={`h-5 w-5 ${
            data.risk === "high" ? "text-red-500" : 
            data.risk === "medium" ? "text-amber-500" : 
            "text-emerald-500"
          }`} />
          {data.city}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-3">
          <div className="flex items-center justify-between text-sm">
            <span className="flex items-center gap-2 text-stone-600 dark:text-stone-400">
              <Users className="h-4 w-4" /> Üretici
            </span>
            <span className="font-semibold">{data.farmers}</span>
          </div>
          
          <div className="flex items-center justify-between text-sm">
            <span className="flex items-center gap-2 text-stone-600 dark:text-stone-400">
              <Clock className="h-4 w-4" /> Bekleyen Başvuru
            </span>
            <span className="font-semibold">{data.pending}</span>
          </div>

          <div className="pt-2 border-t dark:border-stone-800 flex items-center justify-between text-xs">
            <span className="text-stone-500">Risk Seviyesi</span>
            <span className={`font-medium ${
               data.risk === "high" ? "text-red-600" : 
               data.risk === "medium" ? "text-amber-600" : 
               "text-emerald-600"
            }`}>
              {data.risk === "high" ? "Yüksek" : data.risk === "medium" ? "Orta" : "Düşük"}
            </span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
