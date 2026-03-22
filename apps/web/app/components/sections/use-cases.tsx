import { BlurFade } from '@/components/magicui/blur-fade'

const PROCESS_LIST = [
  { port: 3000, name: 'Next.js', color: '#fafafa' },
  { port: 8080, name: 'Python HTTP', color: '#3b82f6' },
  { port: 5432, name: 'PostgreSQL', color: '#22c55e' },
  { port: 6379, name: 'Redis', color: '#ef4444' },
  { port: 9000, name: 'Vite', color: '#a78bfa' },
]

const LOG_LINES = [
  { level: 'INFO', text: 'Process scan completed — 5 processes found', color: '#22c55e' },
  { level: 'INFO', text: 'Port 3000 → Next.js (node, pid 1234)', color: '#22c55e' },
  { level: 'WARN', text: 'Port 8080 in use since 3 hours ago', color: '#f59e0b' },
  { level: 'INFO', text: 'Port 5432 → PostgreSQL (pid 567)', color: '#22c55e' },
  { level: 'ERROR', text: 'Port 9000 → process not responding', color: '#ef4444' },
]

const FRAMEWORK_ICONS = [
  { name: 'nodedotjs', label: 'Node.js' },
  { name: 'python', label: 'Python' },
  { name: 'ruby', label: 'Ruby' },
  { name: 'go', label: 'Go' },
  { name: 'rust', label: 'Rust' },
  { name: 'docker', label: 'Docker' },
]

export default function UseCases() {
  return (
    <section className="px-4 py-24 md:py-32">
      <div className="mx-auto max-w-6xl">
        <BlurFade delay={0} inView>
          <div className="mb-12 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-[#fafafa] sm:text-4xl">
              Use Cases
            </h2>
            <p className="mt-4 text-[#a1a1aa]">
              Everything Rescue does for your dev workflow.
            </p>
          </div>
        </BlurFade>

        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
          {/* Card 1 — wide */}
          <BlurFade delay={0.1} inView className="md:col-span-2">
            <div className="rounded-xl border border-white/10 bg-[#18181b] p-6 hover:border-white/20 transition-colors duration-200">
              <div className="flex flex-col gap-6 lg:flex-row lg:items-start lg:gap-10">
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-[#fafafa] mb-2">
                    Find forgotten dev servers
                  </h3>
                  <p className="text-sm text-[#a1a1aa] leading-relaxed">
                    Automatically detect all running development servers and services on your Mac.
                  </p>
                </div>
                <div className="flex-1 space-y-2">
                  {PROCESS_LIST.map((p) => (
                    <div
                      key={p.port}
                      className="flex items-center justify-between rounded-lg border border-white/5 bg-[#09090b] px-4 py-2.5"
                    >
                      <span className="font-mono text-sm text-[#a1a1aa]">:{p.port}</span>
                      <span className="text-sm font-medium" style={{ color: p.color }}>
                        {p.name}
                      </span>
                      <button className="rounded-md px-2 py-1 text-xs text-[#a1a1aa] hover:bg-white/5 hover:text-[#fafafa] transition-colors">
                        Kill
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </BlurFade>

          {/* Card 2 */}
          <BlurFade delay={0.2} inView>
            <div className="rounded-xl border border-white/10 bg-[#18181b] p-6 hover:border-white/20 transition-colors duration-200 h-full">
              <h3 className="text-lg font-semibold text-[#fafafa] mb-2">
                Monitor process activity
              </h3>
              <p className="text-sm text-[#a1a1aa] leading-relaxed mb-4">
                Track what's running, when it started, and how much memory it's using.
              </p>
              <div className="rounded-lg border border-white/5 bg-[#09090b] p-3 font-mono text-xs space-y-1.5">
                {LOG_LINES.map((line) => (
                  <div key={line.text} className="flex items-start gap-2">
                    <span className="shrink-0 font-bold" style={{ color: line.color }}>
                      {line.level}
                    </span>
                    <span className="text-[#a1a1aa]">{line.text}</span>
                  </div>
                ))}
              </div>
            </div>
          </BlurFade>

          {/* Card 3 */}
          <BlurFade delay={0.3} inView>
            <div className="rounded-xl border border-white/10 bg-[#18181b] p-6 hover:border-white/20 transition-colors duration-200 h-full">
              <h3 className="text-lg font-semibold text-[#fafafa] mb-2">
                Works with all frameworks
              </h3>
              <p className="text-sm text-[#a1a1aa] leading-relaxed mb-4">
                Rescue detects processes from Node.js, Python, Ruby, Go, Rust and more.
              </p>
              <div className="grid grid-cols-3 gap-3">
                {FRAMEWORK_ICONS.map((icon) => (
                  <div
                    key={icon.name}
                    className="flex flex-col items-center gap-2 rounded-lg border border-white/5 bg-[#09090b] px-3 py-3 hover:border-white/10 transition-colors"
                  >
                    <img
                      src={`https://cdn.simpleicons.org/${icon.name}/ffffff`}
                      alt={icon.label}
                      className="h-6 w-6 opacity-60"
                    />
                    <span className="text-xs text-[#a1a1aa]">{icon.label}</span>
                  </div>
                ))}
              </div>
            </div>
          </BlurFade>
        </div>
      </div>
    </section>
  )
}
