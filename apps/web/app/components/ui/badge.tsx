import { cn } from '@/lib/utils'

interface BadgeProps {
  children: React.ReactNode
  className?: string
  variant?: 'default' | 'accent'
}

export function Badge({ children, className, variant = 'default' }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-medium',
        {
          'border border-white/10 bg-white/5 text-[#94a3b8]': variant === 'default',
          'border border-[#f97316]/30 bg-[#f97316]/10 text-[#fb923c]':
            variant === 'accent',
        },
        className,
      )}
    >
      {children}
    </span>
  )
}
