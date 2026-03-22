import { cn } from '@/lib/utils'

interface MarqueeProps {
  readonly className?: string
  readonly reverse?: boolean
  readonly pauseOnHover?: boolean
  readonly children?: React.ReactNode
  readonly vertical?: boolean
  readonly repeat?: number
  readonly duration?: string
  readonly gap?: string
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
        // eslint-disable-next-line react-x/no-array-index-key -- repeated clones have no stable identity
        <div key={i}
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
