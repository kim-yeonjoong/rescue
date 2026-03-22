import { cn } from '@/lib/utils'

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'ghost' | 'outline' | 'white'
  size?: 'sm' | 'md' | 'lg'
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
        'inline-flex items-center justify-center gap-2 font-medium transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-violet-500/50 disabled:opacity-50',
        {
          'rounded-lg bg-violet-500 text-white hover:bg-violet-600 shadow-lg shadow-violet-500/20':
            variant === 'default',
          'bg-transparent text-white/60 hover:text-white hover:bg-white/5 rounded-lg':
            variant === 'ghost',
          'rounded-lg border border-white/20 bg-transparent text-white hover:bg-white/5':
            variant === 'outline',
          'rounded-full bg-white text-black hover:bg-white/90':
            variant === 'white',
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
