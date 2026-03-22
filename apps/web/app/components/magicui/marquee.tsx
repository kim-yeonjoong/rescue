import { cn } from '@/lib/utils'

interface MarqueeProps {
  className?: string
  reverse?: boolean
  pauseOnHover?: boolean
  children?: React.ReactNode
  vertical?: boolean
  repeat?: number
  duration?: string
  gap?: string
}

export function Marquee({
  className,
  reverse,
  pauseOnHover = false,
  children,
  vertical = false,
  repeat = 4,
  duration = '40s',
  gap = '1rem',
}: MarqueeProps) {
  return (
    <div
      className={cn(
        'group flex overflow-hidden p-2 [--duration:40s] [--gap:1rem]',
        {
          'flex-row': !vertical,
          'flex-col': vertical,
        },
        className,
      )}
      style={{ '--duration': duration, '--gap': gap } as React.CSSProperties}
    >
      {Array.from({ length: repeat }).map((_, i) => (
        <div
          key={i}
          className={cn('flex shrink-0 justify-around gap-[--gap]', {
            'animate-marquee flex-row': !vertical && !reverse,
            'animate-marquee-reverse flex-row': !vertical && reverse,
            '[animation-play-state:paused]': pauseOnHover,
          })}
          style={
            pauseOnHover
              ? undefined
              : { animationPlayState: 'running' }
          }
          onMouseEnter={(e) => {
            if (pauseOnHover) {
              ;(e.currentTarget as HTMLElement).style.animationPlayState =
                'paused'
            }
          }}
          onMouseLeave={(e) => {
            if (pauseOnHover) {
              ;(e.currentTarget as HTMLElement).style.animationPlayState =
                'running'
            }
          }}
        >
          {children}
        </div>
      ))}
    </div>
  )
}
