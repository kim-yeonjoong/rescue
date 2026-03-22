import { AnimatedShinyText } from '@/components/magicui/animated-shiny-text'
import { BlurFade } from '@/components/magicui/blur-fade'
import { Button } from '@/components/ui/button'

const RELEASES_URL = 'https://github.com/pointnemo/rescue/releases/latest'

export default function Hero() {
  return (
    <section className="relative px-4 py-24 md:py-32 overflow-hidden">
      {/* Background glow */}
      <div className="pointer-events-none absolute inset-0 flex items-start justify-center">
        <div className="h-[500px] w-[900px] -translate-y-1/4 rounded-full bg-[#f97316]/6 blur-[140px]" />
      </div>

      <div className="mx-auto max-w-6xl">
        <div className="flex flex-col items-start gap-12 lg:flex-row lg:items-center lg:gap-16">
          {/* Left content */}
          <div className="flex-1 space-y-6">
            <BlurFade delay={0} inView>
              <div className="inline-flex items-center rounded-full border border-white/10 bg-[#18181b] px-4 py-1.5 text-sm text-[#a1a1aa]">
                <span className="mr-2">🚀</span>
                <span className="text-[#fafafa] font-medium">New</span>
                <span className="mx-2">Rescue v0.1.7 released</span>
                <span className="text-[#f97316]">→</span>
              </div>
            </BlurFade>

            <BlurFade delay={0.1} inView>
              <h1 className="text-5xl font-bold tracking-tight sm:text-6xl lg:text-7xl">
                <AnimatedShinyText className="text-5xl font-bold tracking-tight sm:text-6xl lg:text-7xl">
                  Rescue
                </AnimatedShinyText>
              </h1>
            </BlurFade>

            <BlurFade delay={0.2} inView>
              <p className="max-w-lg text-lg text-[#a1a1aa] leading-relaxed">
                Find and manage forgotten development processes running on your Mac.
                One click to see what's hogging your ports.
              </p>
            </BlurFade>

            <BlurFade delay={0.3} inView>
              <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
                <a href={RELEASES_URL} target="_blank" rel="noopener noreferrer">
                  <Button size="lg">
                    <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                    </svg>
                    Download for macOS
                  </Button>
                </a>
                <span className="text-sm text-[#a1a1aa]">Free, open source for macOS</span>
              </div>
            </BlurFade>
          </div>

          {/* Right screenshot */}
          <BlurFade delay={0.4} inView className="flex-1 w-full">
            <div className="relative rounded-2xl border border-white/10 bg-[#18181b] shadow-2xl shadow-black/50 overflow-hidden aspect-video flex items-center justify-center">
              <div className="text-center text-[#a1a1aa] p-8">
                <div className="text-6xl mb-4">🖥️</div>
                <p className="text-sm">Rescue App Screenshot</p>
              </div>
            </div>
          </BlurFade>
        </div>
      </div>
    </section>
  )
}
