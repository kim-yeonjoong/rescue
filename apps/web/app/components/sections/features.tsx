import { BentoGrid, BentoCard } from '@/components/magicui/bento-grid'
import { BlurFade } from '@/components/magicui/blur-fade'
import { MagicCard } from '@/components/magicui/magic-card'

const features = [
  {
    icon: '🔍',
    title: 'Port Scanning',
    description:
      'Automatically scans all active ports and surfaces what\'s running — no manual netstat needed.',
    span: 'md:col-span-2',
  },
  {
    icon: '🧠',
    title: 'Framework Detection',
    description:
      'Recognizes 30+ frameworks and shows them by name, not just a port number.',
    span: '',
  },
  {
    icon: '🐳',
    title: 'Docker Support',
    description:
      'Detects Docker containers and shows which ports they expose alongside your native processes.',
    span: '',
  },
  {
    icon: '👻',
    title: 'Portless Processes',
    description:
      'Catches background processes that don\'t bind to a port so nothing slips through the cracks.',
    span: '',
  },
  {
    icon: '⚡',
    title: 'Process Control',
    description:
      'Open in browser, copy URL, or kill processes directly from the menu bar without touching a terminal.',
    span: 'md:col-span-2',
  },
  {
    icon: '🔎',
    title: 'Spotlight Search',
    description:
      'Filter processes instantly with keyboard-first search — find anything in milliseconds.',
    span: '',
  },
]

export default function Features() {
  return (
    <section className="px-4 py-24 md:py-32">
      <div className="mx-auto max-w-6xl">
        <BlurFade inView delay={0}>
          <div className="mb-12 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-[#f1f5f9] sm:text-4xl">
              Everything you need to stay in control
            </h2>
            <p className="mt-4 text-[#94a3b8]">
              Rescue gives you complete visibility into your dev environment.
            </p>
          </div>
        </BlurFade>

        <BentoGrid>
          {features.map((feature, i) => (
            // BlurFade's motion.div is the grid item — span class goes here
            <BlurFade key={feature.title} inView delay={0.05 * i} className={feature.span}>
              <MagicCard className="h-full">
                <BentoCard className="h-full border-0 bg-transparent">
                  <div className="text-3xl mb-4">{feature.icon}</div>
                  <h3 className="text-base font-semibold text-[#f1f5f9] mb-2">
                    {feature.title}
                  </h3>
                  <p className="text-sm text-[#94a3b8] leading-relaxed">
                    {feature.description}
                  </p>
                </BentoCard>
              </MagicCard>
            </BlurFade>
          ))}
        </BentoGrid>
      </div>
    </section>
  )
}
