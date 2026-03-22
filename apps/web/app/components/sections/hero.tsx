import { BlurFade } from '@/components/magicui/blur-fade'

const RELEASES_URL = 'https://github.com/pointnemo/rescue/releases/latest'

export default function Hero() {
  return (
    <section className="px-10 py-20">
      <div className="flex flex-col gap-12 lg:flex-row lg:items-center lg:gap-16">
        {/* Left content */}
        <div className="flex-1 space-y-6">
          <BlurFade delay={0} inView>
            <div className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-4 py-1.5 text-sm">
              <span className="rounded-full bg-white/10 px-2 py-0.5 text-xs font-medium text-white">
                🚀 New
              </span>
              <span className="text-white/60">Rescue v0.1 released</span>
              <svg className="h-3 w-3 text-white/40" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </div>
          </BlurFade>

          <BlurFade delay={0.1} inView>
            <h1 className="text-6xl font-bold tracking-tight sm:text-7xl lg:text-8xl bg-gradient-to-r from-cyan-400 via-green-400 to-yellow-400 bg-clip-text text-transparent leading-tight">
              Rescue
            </h1>
          </BlurFade>

          <BlurFade delay={0.2} inView>
            <p className="max-w-md text-base text-white/60 leading-relaxed">
              Find and manage forgotten development processes running on your Mac.
              One click to see what's hogging your ports.
            </p>
          </BlurFade>

          <BlurFade delay={0.3} inView>
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
              <a href={RELEASES_URL} target="_blank" rel="noopener noreferrer">
                <button className="inline-flex items-center gap-2 rounded-lg bg-violet-500 px-5 py-2.5 text-sm font-medium text-white hover:bg-violet-600 transition-colors shadow-lg shadow-violet-500/20">
                  <span className="font-mono text-xs">&gt;_</span>
                  Download for macOS
                </button>
              </a>
              <span className="text-sm text-white/40">Free, open source, macOS native</span>
            </div>
          </BlurFade>
        </div>

        {/* Right decorative element */}
        <BlurFade delay={0.4} inView className="flex-1 w-full">
          <div className="relative aspect-square max-w-[320px] mx-auto lg:mx-0 lg:ml-auto">
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="relative w-48 h-48">
                <div className="absolute inset-0 rounded-2xl bg-violet-500/20 blur-2xl" />
                <div className="absolute inset-4 rounded-2xl border border-white/10 bg-[#111111] flex items-center justify-center">
                  <div className="space-y-2 w-full px-4">
                    {[
                      { port: ':3000', name: 'Next.js', color: 'text-white' },
                      { port: ':8080', name: 'Python', color: 'text-blue-400' },
                      { port: ':5432', name: 'Postgres', color: 'text-green-400' },
                      { port: ':6379', name: 'Redis', color: 'text-red-400' },
                    ].map((p) => (
                      <div key={p.port} className="flex items-center justify-between rounded border border-white/5 bg-[#0a0a0a] px-2.5 py-1.5">
                        <span className="font-mono text-[10px] text-white/40">{p.port}</span>
                        <span className={`text-[10px] font-medium ${p.color}`}>{p.name}</span>
                        <span className="text-[9px] text-white/30">Kill</span>
                      </div>
                    ))}
                  </div>
                </div>
                <div className="absolute -top-1 -right-1 h-3 w-3 rounded-full bg-violet-500/60" />
                <div className="absolute -bottom-1 -left-1 h-2 w-2 rounded-full bg-cyan-500/60" />
              </div>
            </div>
          </div>
        </BlurFade>
      </div>
    </section>
  )
}
