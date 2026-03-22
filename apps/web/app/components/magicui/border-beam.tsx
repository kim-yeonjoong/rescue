import { cn } from '@/lib/utils'

interface BorderBeamProps {
  className?: string
  size?: number
  duration?: number
  anchor?: number
  borderWidth?: number
  colorFrom?: string
  colorTo?: string
  delay?: number
}

export function BorderBeam({
  className,
  size = 200,
  duration = 15,
  anchor = 90,
  borderWidth = 1.5,
  colorFrom = '#f97316',
  colorTo = '#fb923c',
  delay = 0,
}: BorderBeamProps) {
  return (
    <div
      style={
        {
          '--size': size,
          '--duration': duration,
          '--anchor': anchor,
          '--border-width': borderWidth,
          '--color-from': colorFrom,
          '--color-to': colorTo,
          '--delay': `-${delay}s`,
        } as React.CSSProperties
      }
      className={cn(
        'pointer-events-none absolute inset-0 rounded-[inherit] [border:calc(var(--border-width)*1px)_solid_transparent]',
        '[background:linear-gradient(transparent,transparent),linear-gradient(to_right,var(--color-from),var(--color-to))]',
        '[background-clip:padding-box,border-box] [background-origin:border-box]',
        '[mask:linear-gradient(transparent,transparent),linear-gradient(white,white)]',
        '[mask-clip:padding-box,border-box] [mask-composite:intersect]',
        'animate-border-beam',
        className,
      )}
    />
  )
}
