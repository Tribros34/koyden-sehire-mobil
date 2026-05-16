"use client";

import { useQuery } from "@tanstack/react-query";
import { Network, ShieldCheck, User } from "lucide-react";
import Link from "next/link";
import { PageHeader } from "@/components/admin/PageHeader";
import { Card, CardContent } from "@/components/ui/card";
import { adminApi } from "@/lib/api";
import { InviteNode } from "@/lib/types";

export default function InviteNetworkPage() {
  const { data: network, isLoading } = useQuery({
    queryKey: ["inviteNetwork"],
    queryFn: () => adminApi.getInviteNetwork(),
  });

  if (isLoading) {
    return (
      <div className="space-y-6">
        <PageHeader title="Davet Ağı" />
        <div className="h-96 animate-pulse rounded-md bg-stone-100 dark:bg-stone-800" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title="Davet Ağı"
        description="Üreticilerin birbirini davet zinciri ve güven aktarımı."
      />

      <Card className="overflow-x-auto">
        <CardContent className="min-w-[800px] p-8">
          {network && <NetworkTree node={network} />}
        </CardContent>
      </Card>
    </div>
  );
}

function NetworkTree({ node, isRoot = true }: { node: InviteNode; isRoot?: boolean }) {
  const hasChildren = node.children && node.children.length > 0;

  return (
    <div className="flex flex-col items-center">
      {/* Node Card */}
      <div
        className={`relative z-10 flex w-64 flex-col items-center rounded-lg border bg-white p-4 text-center shadow-sm dark:bg-stone-950 ${
          isRoot
            ? "border-emerald-500 shadow-emerald-500/20"
            : "border-stone-200 dark:border-stone-800"
        }`}
      >
        <div
          className={`mb-3 flex h-12 w-12 items-center justify-center rounded-full ${
            isRoot
              ? "bg-emerald-100 text-emerald-600 dark:bg-emerald-900/50"
              : "bg-stone-100 text-stone-600 dark:bg-stone-900"
          }`}
        >
          {isRoot ? <Network className="h-6 w-6" /> : <User className="h-6 w-6" />}
        </div>
        
        {isRoot ? (
          <span className="font-bold text-emerald-700 dark:text-emerald-500">{node.name}</span>
        ) : (
          <Link href={`/admin/farmers/${node.id}`} className="font-semibold hover:underline">
            {node.name}
          </Link>
        )}
        
        <div className="mt-2 text-xs text-stone-500">
          <p>{node.city}</p>
          <p className="font-mono mt-1 text-[10px]">{node.code}</p>
        </div>
        
        {!isRoot && (
          <div className="mt-3 flex items-center justify-center gap-1 rounded-full bg-stone-50 px-2 py-1 text-xs font-medium dark:bg-stone-900">
            <ShieldCheck className={`h-3.5 w-3.5 ${node.trust_score >= 80 ? "text-emerald-500" : node.trust_score >= 50 ? "text-amber-500" : "text-red-500"}`} />
            Güven Skoru: {node.trust_score}
          </div>
        )}
      </div>

      {/* Connection Lines & Children */}
      {hasChildren && (
        <div className="relative mt-8 flex justify-center gap-8 pt-8">
          {/* Vertical line from parent to horizontal line */}
          <div className="absolute top-0 -mt-8 h-8 w-px bg-stone-300 dark:bg-stone-700" />
          
          {/* Horizontal line connecting children */}
          {node.children!.length > 1 && (
            <div className="absolute top-0 h-px w-[calc(100%-16rem)] bg-stone-300 dark:bg-stone-700" />
          )}

          {node.children!.map((child, index) => (
            <div key={child.id} className="relative flex flex-col items-center">
              {/* Vertical line from horizontal line down to child */}
              <div className="absolute top-0 -mt-8 h-8 w-px bg-stone-300 dark:bg-stone-700" />
              <NetworkTree node={child} isRoot={false} />
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
