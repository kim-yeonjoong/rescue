import { BlurFade } from '@/components/magicui/blur-fade'

const LOGOS = [
  { name: 'github', label: 'GitHub' },
  { name: 'docker', label: 'Docker' },
  { name: 'python', label: 'Python' },
  { name: 'nodedotjs', label: 'Node.js' },
  { name: 'apple', label: 'macOS' },
  { name: 'visualstudiocode', label: 'VS Code' },
]

export default function Logos() {
  return (
    <section className="border-t border-white/10 px-10 py-8">
      <BlurFade delay={0} inView>
        <p className="mb-6 text-center text-xs text-white/30 uppercase tracking-widest">
          Detects processes from all major runtimes
        </p>
        <div className="flex items-center justify-center gap-0">
          {LOGOS.map((logo, i) => (
            <div key={logo.name} className="flex flex-col items-center gap-2 px-6 py-2 opacity-30 grayscale hover:opacity-60 hover:grayscale-0 transition-all duration-300" style={i > 0 ? { borderLeft: '1px solid rgba(255,255,255,0.08)' } : {}}>
              <img
                src={`https://cdn.simpleicons.org/${logo.name}/ffffff`}
                alt={logo.label}
                className="h-5 w-5"
              />
              <span className="text-[10px] text-white/40">{logo.label}</span>
            </div>
          ))}
        </div>
      </BlurFade>
    </section>
  )
}
