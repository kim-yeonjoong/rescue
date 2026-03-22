import { BlurFade } from '@/components/magicui/blur-fade'

const STATS = [
  {
    value: '30+',
    label: 'Detected Frameworks',
    icon: (
      <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z" />
      </svg>
    ),
  },
  {
    value: '0ms',
    label: 'Scanning Overhead',
    icon: (
      <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z" />
      </svg>
    ),
  },
  {
    value: '100%',
    label: 'Free & Open Source',
    icon: (
      <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
  },
]

export default function Stats() {
  return (
    <section>
      <div className="grid grid-cols-1 divide-y divide-white/10 border-t border-white/10 sm:grid-cols-3 sm:divide-x sm:divide-y-0">
          {STATS.map((stat, i) => (
            <BlurFade key={stat.label} delay={0.05 * i} inView>
              <div className="flex flex-col items-center px-8 py-12 text-center">
                {/* Huge muted number */}
                <div className="text-[80px] font-bold leading-none tracking-tight text-white/[0.08] sm:text-[100px]">
                  {stat.value}
                </div>
                {/* Icon + label */}
                <div className="mt-4 flex items-center gap-2 text-white/40">
                  {stat.icon}
                  <span className="text-xs font-medium">{stat.label}</span>
                </div>
              </div>
            </BlurFade>
          ))}
        </div>
    </section>
  )
}
