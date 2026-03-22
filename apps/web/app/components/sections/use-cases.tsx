import { BlurFade } from '@/components/magicui/blur-fade'

const PROCESS_LIST = [
  { port: ':3000', name: 'Next.js', color: 'text-white' },
  { port: ':8080', name: 'Python HTTP', color: 'text-blue-400' },
  { port: ':5432', name: 'PostgreSQL', color: 'text-green-400' },
]

const LOG_LINES = [
  { time: '09:41:02', level: 'INFO', text: 'Scan completed — 5 processes found', levelColor: 'text-green-400' },
  { time: '09:41:02', level: 'INFO', text: 'Port 3000 → Next.js (node, pid 1234)', levelColor: 'text-green-400' },
  { time: '09:41:05', level: 'WARN', text: 'Port 8080 in use since 3 hours ago', levelColor: 'text-yellow-400' },
  { time: '09:41:07', level: 'ACTION', text: 'User killed process on :9000', levelColor: 'text-violet-400' },
  { time: '09:41:10', level: 'ERROR', text: 'Port 9200 → process not responding', levelColor: 'text-red-400' },
]

const FRAMEWORK_LOGOS = [
  { name: 'nodedotjs', label: 'Node', color: '#339933' },
  { name: 'python', label: 'Python', color: '#3776AB' },
  { name: 'ruby', label: 'Ruby', color: '#CC342D' },
  { name: 'go', label: 'Go', color: '#00ADD8' },
  { name: 'rust', label: 'Rust', color: '#CE422B' },
  { name: 'docker', label: 'Docker', color: '#2496ED' },
]

export default function UseCases() {
  return (
    <section>
      <div className="grid grid-cols-1 divide-y divide-white/10 border-t border-white/10 lg:grid-cols-3 lg:divide-x lg:divide-y-0">

          {/* Card 1 — Find forgotten dev servers */}
          <BlurFade delay={0.05} inView>
            <div className="flex flex-col p-8">
              {/* Visual mockup */}
              <div className="mb-6 flex-1 space-y-2 rounded-lg border border-white/10 bg-[#0a0a0a] p-4">
                <div className="mb-3 flex items-center gap-2 rounded border border-white/5 bg-white/3 px-3 py-2">
                  <svg className="h-3 w-3 text-white/30" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 111 11a6 6 0 0116 0z" />
                  </svg>
                  <span className="text-[11px] text-white/20">Search processes...</span>
                </div>
                {PROCESS_LIST.map((p) => (
                  <div
                    key={p.port}
                    className="flex items-center justify-between rounded border border-white/5 bg-[#111111] px-3 py-2"
                  >
                    <span className="font-mono text-[11px] text-white/40">{p.port}</span>
                    <span className={`text-[11px] font-medium ${p.color}`}>{p.name}</span>
                    <span className="rounded px-1.5 py-0.5 text-[10px] text-white/30 hover:bg-white/5 cursor-pointer">Kill</span>
                  </div>
                ))}
              </div>
              <h3 className="text-sm font-semibold text-white mb-1.5">Find forgotten dev servers</h3>
              <p className="text-xs text-white/50 leading-relaxed">
                Automatically detect all running development servers and services on your Mac.
              </p>
            </div>
          </BlurFade>

          {/* Card 2 — Monitor process activity */}
          <BlurFade delay={0.1} inView>
            <div className="flex flex-col p-8">
              {/* Log mockup */}
              <div className="mb-6 flex-1 rounded-lg border border-white/10 bg-[#0a0a0a] p-4 font-mono text-[10px] space-y-1.5">
                {LOG_LINES.map((line) => (
                  <div key={line.text} className="flex items-start gap-2">
                    <span className="text-white/20 shrink-0">{line.time}</span>
                    <span className={`shrink-0 font-bold ${line.levelColor}`}>{line.level}</span>
                    <span className="text-white/40 leading-relaxed">{line.text}</span>
                  </div>
                ))}
              </div>
              <h3 className="text-sm font-semibold text-white mb-1.5">Monitor process activity</h3>
              <p className="text-xs text-white/50 leading-relaxed">
                Track what's running, when it started, and how much memory it's using.
              </p>
            </div>
          </BlurFade>

          {/* Card 3 — Works with all frameworks */}
          <BlurFade delay={0.15} inView>
            <div className="flex flex-col p-8">
              {/* Circular network visualization */}
              <div className="mb-6 flex-1 flex items-center justify-center rounded-lg border border-white/10 bg-[#0a0a0a] py-8">
                <div className="relative h-36 w-36">
                  {/* Center circle */}
                  <div className="absolute inset-[40%] rounded-full border border-violet-500/40 bg-violet-500/10 flex items-center justify-center">
                    <div className="h-1.5 w-1.5 rounded-full bg-violet-400" />
                  </div>
                  {/* Outer ring */}
                  <div className="absolute inset-0 rounded-full border border-white/5" />
                  {/* Framework icons around the circle */}
                  {FRAMEWORK_LOGOS.map((logo, i) => {
                    const angle = (i / FRAMEWORK_LOGOS.length) * 2 * Math.PI - Math.PI / 2
                    const radius = 52
                    const x = 50 + radius * Math.cos(angle)
                    const y = 50 + radius * Math.sin(angle)
                    return (
                      <div
                        key={logo.name}
                        className="absolute flex h-7 w-7 items-center justify-center rounded-full border border-white/10 bg-[#111111] -translate-x-1/2 -translate-y-1/2"
                        style={{ left: `${x}%`, top: `${y}%` }}
                      >
                        <img
                          src={`https://cdn.simpleicons.org/${logo.name}/ffffff`}
                          alt={logo.label}
                          className="h-3.5 w-3.5 opacity-60"
                        />
                      </div>
                    )
                  })}
                </div>
              </div>
              <h3 className="text-sm font-semibold text-white mb-1.5">Works with all frameworks</h3>
              <p className="text-xs text-white/50 leading-relaxed">
                Rescue detects processes from Node.js, Python, Ruby, Go, Rust and Docker.
              </p>
            </div>
          </BlurFade>
        </div>
    </section>
  )
}
