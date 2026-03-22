import { BlurFade } from '@/components/magicui/blur-fade'

const RELEASES_URL = 'https://github.com/pointnemo/rescue/releases/latest'

export default function Cta() {
  return (
    <section>
      <div className="border-t border-white/10 px-10 py-20 text-center">
        <BlurFade delay={0} inView>
          <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl mb-4">
            Ready to rescue your dev workflow?
          </h2>
          <p className="text-sm text-white/50 mb-8 max-w-sm mx-auto leading-relaxed">
            Join developers who never lose track of their processes.
          </p>
          <a href={RELEASES_URL} target="_blank" rel="noopener noreferrer">
            <button className="inline-flex items-center gap-2 rounded-full bg-violet-500 px-6 py-3 text-sm font-medium text-white hover:bg-violet-600 transition-colors shadow-lg shadow-violet-500/20">
              Get Started
            </button>
          </a>
        </BlurFade>
      </div>
    </section>
  )
}
