import { BlurFade } from '@/components/magicui/blur-fade'

const LOGOS = [
  { name: 'nodedotjs', label: 'Node.js' },
  { name: 'python', label: 'Python' },
  { name: 'docker', label: 'Docker' },
  { name: 'rust', label: 'Rust' },
  { name: 'go', label: 'Go' },
  { name: 'ruby', label: 'Ruby' },
]

export default function Logos() {
  return (
    <section className="px-4 py-12 border-y border-white/10">
      <div className="mx-auto max-w-6xl">
        <BlurFade delay={0} inView>
          <p className="mb-8 text-center text-sm text-[#a1a1aa]">
            Detects processes from all major runtimes
          </p>
          <div className="flex items-center justify-center gap-10 flex-wrap">
            {LOGOS.map((logo) => (
              <div key={logo.name} className="flex flex-col items-center gap-2 opacity-40 grayscale hover:opacity-70 hover:grayscale-0 transition-all duration-300">
                <img
                  src={`https://cdn.simpleicons.org/${logo.name}/ffffff`}
                  alt={logo.label}
                  className="h-8 w-8"
                />
                <span className="text-xs text-[#a1a1aa]">{logo.label}</span>
              </div>
            ))}
          </div>
        </BlurFade>
      </div>
    </section>
  )
}
