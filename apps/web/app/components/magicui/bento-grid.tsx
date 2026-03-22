import { cn } from '@/lib/utils'

interface BentoGridProps {
  readonly children: React.ReactNode
  readonly className?: string
}

export function BentoGrid({ children, className }: BentoGridProps) {
  return (
    <div
      className={cn(
        'grid grid-cols-1 md:grid-cols-3 gap-4 auto-rows-[minmax(160px,auto)]',
        className,
      )}
    >
      {children}
    </div>
  )
}

interface BentoCardProps {
  readonly children: React.ReactNode
  readonly className?: string
}

export function BentoCard({ children, className }: BentoCardProps) {
  return (
    <div
      className={cn(
        'group relative rounded-xl border border-white/8 bg-[#0f2040] p-6',
        'transition-colors duration-300 hover:border-white/16',
        className,
      )}
    >
      {children}
    </div>
  )
}
