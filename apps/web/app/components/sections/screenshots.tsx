import { BlurFade } from '@/components/magicui/blur-fade'
import { BorderBeam } from '@/components/magicui/border-beam'

export default function Screenshots() {
  return (
    <section className="px-4 py-24 md:py-32">
      <div className="mx-auto max-w-6xl">
        <BlurFade inView delay={0}>
          <div className="mb-12 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-[#f1f5f9] sm:text-4xl">
              Clean, focused interface
            </h2>
            <p className="mt-4 text-[#94a3b8]">
              Designed to stay out of your way until you need it.
            </p>
          </div>
        </BlurFade>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <BlurFade inView delay={0.1}>
            <div className="relative rounded-2xl border border-white/10 bg-[#0f2040] overflow-hidden shadow-2xl shadow-black/40">
              <BorderBeam size={250} duration={10} colorFrom="#f97316" colorTo="#fb923c" />
              <img
                src="/screenshot1.png"
                alt="Rescue — process list"
                className="w-full rounded-2xl"
              />
            </div>
          </BlurFade>

          <BlurFade inView delay={0.2}>
            <div className="relative rounded-2xl border border-white/10 bg-[#0f2040] overflow-hidden shadow-2xl shadow-black/40">
              <BorderBeam size={250} duration={10} colorFrom="#fb923c" colorTo="#f97316" delay={5} />
              <img
                src="/screenshot2.png"
                alt="Rescue — settings"
                className="w-full rounded-2xl"
              />
            </div>
          </BlurFade>
        </div>
      </div>
    </section>
  )
}
