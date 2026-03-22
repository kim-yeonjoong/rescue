import { BlurFade } from '@/components/magicui/blur-fade'

const FEATURES = [
  {
    icon: '🔍',
    title: 'Process Discovery',
    description: 'Automatically find all running dev servers on your Mac.',
  },
  {
    icon: '🚦',
    title: 'Port Monitoring',
    description: 'See which ports are in use and by which process.',
  },
  {
    icon: '⚡',
    title: 'One-click Kill',
    description: 'Kill any process instantly from your menu bar.',
  },
  {
    icon: '🧠',
    title: 'Framework Detection',
    description: 'Recognizes Node.js, Python, Ruby, Go, Docker and more.',
  },
  {
    icon: '🍎',
    title: 'Menu Bar Native',
    description: 'Lives in your macOS menu bar, always accessible.',
  },
  {
    icon: '🔄',
    title: 'Auto-start',
    description: 'Launches automatically when you log in to macOS.',
  },
]

export default function Features() {
  return (
    <section className="px-4 py-24 md:py-32">
      <div className="mx-auto max-w-6xl">
        <BlurFade delay={0} inView>
          <div className="mb-12 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-[#fafafa] sm:text-4xl">
              Features
            </h2>
            <p className="mt-4 text-[#a1a1aa]">
              Everything you need to stay in control of your dev environment.
            </p>
          </div>
        </BlurFade>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {FEATURES.map((feature, i) => (
            <BlurFade key={feature.title} delay={0.05 * i} inView>
              <div className="rounded-xl border border-white/10 bg-[#18181b] p-6 hover:border-white/20 transition-colors duration-200 h-full">
                <div className="mb-4 text-3xl">{feature.icon}</div>
                <h3 className="mb-2 text-base font-semibold text-[#fafafa]">
                  {feature.title}
                </h3>
                <p className="text-sm text-[#a1a1aa] leading-relaxed">
                  {feature.description}
                </p>
                <div className="mt-4">
                  <span className="text-xs text-[#f97316] hover:underline cursor-pointer">
                    Learn more &gt;
                  </span>
                </div>
              </div>
            </BlurFade>
          ))}
        </div>
      </div>
    </section>
  )
}
