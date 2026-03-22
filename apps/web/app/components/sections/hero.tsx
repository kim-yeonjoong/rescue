import { BlurFade } from '@/components/magicui/blur-fade'
import { BorderBeam } from '@/components/magicui/border-beam'
import { AnimatedShinyText } from '@/components/magicui/animated-shiny-text'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'

const RELEASES_URL = 'https://github.com/pointnemo/rescue/releases/latest'
const GITHUB_URL = 'https://github.com/pointnemo/rescue'

export default function Hero() {
  return (
    <section className="relative flex flex-col items-center px-4 pt-24 pb-16 md:pt-32 md:pb-24 text-center overflow-hidden">
      {/* Background glow */}
      <div className="pointer-events-none absolute inset-0 flex items-start justify-center">
        <div className="h-[400px] w-[800px] -translate-y-1/3 rounded-full bg-[#f97316]/8 blur-[120px]" />
      </div>

      <BlurFade delay={0} inView>
        <Badge variant="accent" className="mb-6">
          <span className="mr-1">🍎</span>
          Available for macOS
        </Badge>
      </BlurFade>

      <BlurFade delay={0.1} inView>
        <h1 className="mx-auto max-w-3xl text-4xl font-bold tracking-tight text-[#f1f5f9] sm:text-5xl md:text-6xl lg:text-7xl leading-[1.1]">
          Find the dev processes{' '}
          <span className="text-[#f97316]">you forgot</span>
          {' '}you started.
        </h1>
      </BlurFade>

      <BlurFade delay={0.2} inView>
        <p className="mx-auto mt-6 max-w-xl text-lg text-[#94a3b8] leading-relaxed">
          Rescue scans your ports and surfaces forgotten servers, containers, and
          background processes — right from your macOS menu bar.
        </p>
      </BlurFade>

      <BlurFade delay={0.3} inView>
        <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
          <a href={RELEASES_URL} target="_blank" rel="noopener noreferrer">
            <Button size="lg">
              <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
              Download for Mac
            </Button>
          </a>
          <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer">
            <Button size="lg" variant="outline">
              <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                <path fillRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clipRule="evenodd" />
              </svg>
              View on GitHub
            </Button>
          </a>
        </div>
      </BlurFade>

      {/* App screenshot */}
      <BlurFade delay={0.4} inView className="mt-16 w-full max-w-2xl">
        <div className="relative rounded-2xl border border-white/10 bg-[#0f2040] shadow-2xl shadow-black/50 overflow-hidden">
          <BorderBeam size={300} duration={12} />
          <img
            src="/screenshot1.png"
            alt="Rescue app interface"
            className="w-full rounded-2xl"
          />
        </div>
      </BlurFade>

      <BlurFade delay={0.5} inView>
        <AnimatedShinyText className="mt-8 text-sm">
          Free · Open Source · No telemetry
        </AnimatedShinyText>
      </BlurFade>
    </section>
  )
}
