import { Slot } from "@radix-ui/react-slot";
import { ButtonHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

type Variant = "primary" | "secondary" | "danger" | "ghost" | "outline" | "link" | "default";
type Size = "sm" | "md" | "lg" | "icon";

const variants: Record<Variant, string> = {
  primary: "bg-emerald-700 text-white hover:bg-emerald-800",
  secondary: "bg-stone-900 text-white hover:bg-stone-800 dark:bg-stone-100 dark:text-stone-950",
  danger: "bg-red-600 text-white hover:bg-red-700",
  ghost: "hover:bg-stone-100 dark:hover:bg-stone-800",
  outline: "border border-stone-200 bg-white hover:bg-stone-50 dark:border-stone-800 dark:bg-stone-950 dark:hover:bg-stone-900",
  link: "text-emerald-700 underline-offset-4 hover:underline dark:text-emerald-500",
  default: "bg-emerald-700 text-white hover:bg-emerald-800",
};

const sizes: Record<Size, string> = {
  sm: "h-8 px-3 text-xs",
  md: "h-10 px-4 text-sm",
  lg: "h-11 px-6 text-base",
  icon: "h-9 w-9 p-0",
};

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: Variant;
  size?: Size;
  asChild?: boolean;
};

export function Button({ className, variant = "primary", size = "md", asChild = false, ...props }: ButtonProps) {
  const baseClass = cn(
    "inline-flex items-center justify-center gap-2 rounded-md font-medium transition disabled:pointer-events-none disabled:opacity-50",
    variants[variant],
    sizes[size],
    className,
  );

  if (asChild) {
    return <Slot className={baseClass} {...props} />;
  }

  return <button className={baseClass} {...props} />;
}
