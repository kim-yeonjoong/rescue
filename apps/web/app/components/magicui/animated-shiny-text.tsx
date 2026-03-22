import { cn } from '@/lib/utils'

interface AnimatedShinyTextProps {
  readonly children: React.ReactNode
  readonly className?: string
  readonly shimmerWidth?: number
}

export function AnimatedShinyText({
  children,
  className,
  shimmerWidth = 100,
}: AnimatedShinyTextProps) {
  return (
    <p
      style={{ '--shiny-width': `${shimmerWidth}px` } as React.CSSProperties}
      className={cn(
        'mx-auto max-w-md text-[#94a3b8]/70',
        'animate-shiny-text bg-clip-text bg-no-repeat [background-position:0_0]',
        'bg-[length:var(--shiny-width)_100%]',
        '[background-image:linear-gradient(90deg,transparent_0%,white_50%,transparent_100%)]',
        className,
      )}
    >
      {children}
    </p>
  )
}
