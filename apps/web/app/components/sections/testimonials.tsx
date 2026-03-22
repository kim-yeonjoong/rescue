import { BlurFade } from '@/components/magicui/blur-fade'

const TESTIMONIALS = [
  {
    name: 'Alice Kim',
    handle: '@alice_dev',
    company: 'FrontendCraft',
    body: "Rescue has saved me so much time. I used to forget about dev servers constantly, now they're always visible.",
    color: 'bg-orange-500',
  },
  {
    name: 'Bob Lee',
    handle: '@boblee',
    company: 'DevStudio',
    body: 'The one-click kill feature is a game-changer. No more hunting for PIDs in the terminal.',
    color: 'bg-blue-500',
  },
  {
    name: 'Charlie Park',
    handle: '@cpark',
    company: 'NodeWorks',
    body: "Finally a tool that just works. Rescue sits in my menu bar and I always know what's running.",
    color: 'bg-green-500',
  },
  {
    name: 'Diana Cho',
    handle: '@dianac',
    company: 'PythonLabs',
    body: "I used to have port conflicts daily. Since installing Rescue, I haven't had a single one.",
    color: 'bg-purple-500',
  },
  {
    name: 'Ethan Jung',
    handle: '@ethanj',
    company: 'RustForge',
    body: 'The framework detection is surprisingly accurate. It correctly identifies my Axum and Actix servers.',
    color: 'bg-red-500',
  },
  {
    name: 'Fiona Yoon',
    handle: '@fionay',
    company: 'ReactHouse',
    body: 'Such a simple concept but incredibly useful. Every developer on my team now uses Rescue.',
    color: 'bg-pink-500',
  },
  {
    name: 'George Shin',
    handle: '@gshin',
    company: 'GoLabs',
    body: "Lightweight, fast, and it just works. The auto-start feature means I never forget to run it.",
    color: 'bg-teal-500',
  },
  {
    name: 'Hannah Oh',
    handle: '@hannahoh',
    company: 'DockerCo',
    body: 'Shows my Docker containers right alongside native processes. Absolutely love it.',
    color: 'bg-indigo-500',
  },
  {
    name: 'Ian Kwon',
    handle: '@iankwon',
    company: 'FullstackIO',
    body: "I recommended Rescue to my whole team. It's now part of our standard macOS setup.",
    color: 'bg-yellow-500',
  },
]

function Avatar({ name, color }: { readonly name: string; readonly color: string }) {
  const initials = name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)

  return (
    <div className={`flex h-9 w-9 items-center justify-center rounded-full text-xs font-bold text-white ${color}`}>
      {initials}
    </div>
  )
}

export default function Testimonials() {
  const columns = [
    TESTIMONIALS.slice(0, 3),
    TESTIMONIALS.slice(3, 6),
    TESTIMONIALS.slice(6, 9),
  ]

  return (
    <section>
      <div className="border-t border-white/10">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-white/10 px-8 py-8">
          <div>
            <h2 className="text-2xl font-bold tracking-tight text-white sm:text-3xl">
              What developers say
            </h2>
            <p className="mt-1.5 text-sm text-white/50">
              Trusted by developers who care about their workflow.
            </p>
          </div>
          <a
            href="https://github.com/pointnemo/rescue"
            target="_blank"
            rel="noopener noreferrer"
            className="hidden sm:inline-flex items-center gap-1.5 rounded-full border border-white/10 px-4 py-2 text-xs text-white/50 hover:border-white/20 hover:text-white transition-colors"
          >
            See more
          </a>
        </div>

        {/* 3-column grid */}
        <div className="grid grid-cols-1 divide-y divide-white/10 sm:grid-cols-3 sm:divide-x sm:divide-y-0">
          {columns.map((col, ci) => (
            <div key={col[0]?.name ?? 'col'} className="flex flex-col divide-y divide-white/10">
              {col.map((t, ti) => (
                <BlurFade key={t.name} delay={0.04 * (ci * 3 + ti)} inView>
                  <div className="flex flex-col gap-3 p-6">
                    <div className="flex items-center gap-3">
                      <Avatar name={t.name} color={t.color} />
                      <div>
                        <div className="text-sm font-medium text-white">{t.name}</div>
                        <div className="text-xs text-white/40">{t.handle}</div>
                      </div>
                    </div>
                    <p className="text-sm text-white/60 leading-relaxed">{t.body}</p>
                  </div>
                </BlurFade>
              ))}
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
