import { BlurFade } from '@/components/magicui/blur-fade'
import { Marquee } from '@/components/magicui/marquee'
import { frameworksRow1, frameworksRow2, type Framework } from '@/lib/frameworks'

function FrameworkLogo({ framework }: { readonly framework: Framework }) {
  return (
    <div className="flex flex-col items-center gap-2 px-4">
      <div className="flex h-12 w-12 items-center justify-center rounded-xl border border-white/8 bg-[#0f2040] p-2.5 transition-colors hover:border-white/16">
        <img
          src={`https://cdn.simpleicons.org/${framework.slug}/${framework.color}`}
          alt={framework.name}
          className="h-full w-full object-contain"
          loading="lazy"
        />
      </div>
      <span className="text-xs text-[#94a3b8] whitespace-nowrap">{framework.name}</span>
    </div>
  )
}

export default function FrameworksMarquee() {
  return (
    <section className="py-24 md:py-32 overflow-hidden">
      <div className="mx-auto max-w-6xl px-4">
        <BlurFade inView delay={0}>
          <div className="mb-12 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-[#f1f5f9] sm:text-4xl">
              Detects 30+ frameworks out of the box
            </h2>
            <p className="mt-4 text-[#94a3b8]">
              From React to Rails — Rescue knows what's running.
            </p>
          </div>
        </BlurFade>
      </div>

      <div className="relative flex flex-col gap-4">
        {/* Fade edges */}
        <div className="pointer-events-none absolute inset-y-0 left-0 z-10 w-32 bg-gradient-to-r from-[#0a1628] to-transparent" />
        <div className="pointer-events-none absolute inset-y-0 right-0 z-10 w-32 bg-gradient-to-l from-[#0a1628] to-transparent" />

        <Marquee duration="50s" gap="0px" pauseOnHover repeat={2}>
          {frameworksRow1.map((f) => (
            <FrameworkLogo key={f.name} framework={f} />
          ))}
        </Marquee>

        <Marquee duration="40s" gap="0px" pauseOnHover reverse repeat={2}>
          {frameworksRow2.map((f) => (
            <FrameworkLogo key={f.name} framework={f} />
          ))}
        </Marquee>
      </div>
    </section>
  )
}
