import { cn } from '@/lib/utils'

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'ghost' | 'outline'
  size?: 'sm' | 'md' | 'lg'
  asChild?: boolean
}

export function Button({
  className,
  variant = 'default',
  size = 'md',
  children,
  ...props
}: ButtonProps) {
  return (
    <button
      className={cn(
        'inline-flex items-center justify-center gap-2 rounded-lg font-medium transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#f97316]/50 disabled:opacity-50',
        {
          'bg-[#f97316] text-white hover:bg-[#ea580c] shadow-lg shadow-[#f97316]/20':
            variant === 'default',
          'bg-transparent text-[#94a3b8] hover:text-[#f1f5f9] hover:bg-white/5':
            variant === 'ghost',
          'border border-white/16 bg-transparent text-[#f1f5f9] hover:bg-white/5':
            variant === 'outline',
        },
        {
          'h-8 px-3 text-sm': size === 'sm',
          'h-10 px-4 text-sm': size === 'md',
          'h-12 px-6 text-base': size === 'lg',
        },
        className,
      )}
      {...props}
    >
      {children}
    </button>
  )
}
