import type { Metadata } from "next";
import { Providers } from "@/components/admin/providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "Koyden Sehire Admin",
  description: "Guven, kalite ve operasyon yonetim merkezi",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="tr" className="h-full antialiased" suppressHydrationWarning>
      <body className="min-h-full flex flex-col">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
