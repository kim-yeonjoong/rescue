import { BlurFade } from '@/components/magicui/blur-fade'
import { Button } from '@/components/ui/button'

const RELEASES_URL = 'https://github.com/pointnemo/rescue/releases/latest'

export default function Cta() {
  return (
    <section className="px-4 py-24 md:py-32">
      <div className="mx-auto max-w-6xl">
        <BlurFade delay={0} inView>
          <div className="rounded-xl border border-white/10 bg-[#18181b] px-8 py-16 text-center relative overflow-hidden">
            {/* Background glow */}
            <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
              <div className="h-[300px] w-[600px] rounded-full bg-[#f97316]/8 blur-[100px]" />
            </div>

            <h2 className="relative text-3xl font-bold tracking-tight text-[#fafafa] sm:text-4xl mb-4">
              Ready to rescue your dev workflow?
            </h2>
            <p className="relative text-[#a1a1aa] mb-8 max-w-md mx-auto">
              Join thousands of developers who never lose track of their processes.
            </p>
            <a href={RELEASES_URL} target="_blank" rel="noopener noreferrer" className="relative inline-block">
              <Button size="lg">
                <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                </svg>
                Download for macOS
              </Button>
            </a>
          </div>
        </BlurFade>
      </div>
    </section>
  )
}
