import { BlurFade } from '@/components/magicui/blur-fade'

const STATS = [
  {
    value: '30+',
    label: 'Detected Frameworks',
    icon: (
      <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9.75 3.104v5.714a2.25 2.25 0 01-.659 1.591L5 14.5M9.75 3.104c-.251.023-.501.05-.75.082m.75-.082a24.301 24.301 0 014.5 0m0 0v5.714c0 .597.237 1.17.659 1.591L19.8 15.3M14.25 3.104c.251.023.501.05.75.082M19.8 15.3l-1.57.393A9.065 9.065 0 0112 15a9.065 9.065 0 00-6.23-.693L5 14.5m14.8.8l1.402 1.402c1.232 1.232.65 3.318-1.067 3.611A48.309 48.309 0 0112 21c-2.773 0-5.491-.235-8.135-.687-1.718-.293-2.3-2.379-1.067-3.61L5 14.5" />
      </svg>
    ),
  },
  {
    value: '0ms',
    label: 'Scanning Overhead',
    icon: (
      <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z" />
      </svg>
    ),
  },
  {
    value: '100%',
    label: 'Free & Open Source',
    icon: (
      <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
  },
]

export default function Stats() {
  return (
    <section className="px-4 py-24 md:py-32">
      <div className="mx-auto max-w-6xl">
        <BlurFade delay={0} inView>
          <div className="mb-12 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-[#fafafa] sm:text-4xl">
              Statistics
            </h2>
          </div>
        </BlurFade>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          {STATS.map((stat, i) => (
            <BlurFade key={stat.label} delay={0.1 * i} inView>
              <div className="rounded-xl border border-white/10 bg-[#18181b] p-8 text-center hover:border-white/20 transition-colors duration-200">
                <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-xl border border-white/10 bg-[#09090b] text-[#f97316]">
                  {stat.icon}
                </div>
                <div className="text-6xl font-bold tracking-tight text-[#fafafa] mb-2">
                  {stat.value}
                </div>
                <div className="text-sm text-[#a1a1aa]">{stat.label}</div>
              </div>
            </BlurFade>
          ))}
        </div>
      </div>
    </section>
  )
}
