import { BlurFade } from '@/components/magicui/blur-fade'
import { Button } from '@/components/ui/button'

const RELEASES_URL = 'https://github.com/pointnemo/rescue/releases/latest'

const steps = [
  {
    step: '01',
    title: 'Download',
    description: 'Grab the latest release from GitHub',
    code: 'Rescue.dmg',
  },
  {
    step: '02',
    title: 'Install',
    description: 'Drag Rescue to your Applications folder',
    code: 'Applications →',
  },
  {
    step: '03',
    title: 'Launch',
    description: 'Click the menu bar icon and start rescuing',
    code: '🔴 in menu bar',
  },
]

export default function Install() {
  return (
    <section className="px-4 py-24 md:py-32">
      <div className="mx-auto max-w-4xl">
        <BlurFade inView delay={0}>
          <div className="mb-12 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-[#f1f5f9] sm:text-4xl">
              Get started in seconds
            </h2>
            <p className="mt-4 text-[#94a3b8]">
              No configuration. No account. No nonsense.
            </p>
          </div>
        </BlurFade>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-12">
          {steps.map((step, i) => (
            <BlurFade key={step.step} inView delay={0.1 * (i + 1)}>
              <div className="rounded-xl border border-white/8 bg-[#0f2040] p-6">
                <div className="mb-4 flex items-center justify-between">
                  <span className="text-xs font-mono font-medium text-[#f97316]">
                    STEP {step.step}
                  </span>
                </div>
                <h3 className="mb-1 text-base font-semibold text-[#f1f5f9]">
                  {step.title}
                </h3>
                <p className="mb-4 text-sm text-[#94a3b8]">{step.description}</p>
                <div className="rounded-lg border border-white/8 bg-[#0a1628] px-4 py-2.5 font-mono text-sm text-[#f97316]">
                  {step.code}
                </div>
              </div>
            </BlurFade>
          ))}
        </div>

        <BlurFade inView delay={0.4}>
          <div className="text-center">
            <a href={RELEASES_URL} target="_blank" rel="noopener noreferrer">
              <Button size="lg">
                <svg
                  className="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  strokeWidth={2}
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
                  />
                </svg>
                Download Rescue for Mac
              </Button>
            </a>
            <p className="mt-3 text-xs text-[#94a3b8]">
              Requires macOS 14.0 or later · Free &amp; open source
            </p>
          </div>
        </BlurFade>
      </div>
    </section>
  )
}
