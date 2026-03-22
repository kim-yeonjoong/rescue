import { BlurFade } from '@/components/magicui/blur-fade'

const TESTIMONIALS = [
  {
    name: 'Alice Kim',
    company: 'FrontendCraft',
    body: "Rescue has saved me so much time. I used to forget about dev servers constantly, now they're always visible.",
  },
  {
    name: 'Bob Lee',
    company: 'DevStudio',
    body: 'The one-click kill feature is a game-changer. No more hunting for PIDs in the terminal.',
  },
  {
    name: 'Charlie Park',
    company: 'NodeWorks',
    body: "Finally a tool that just works. Rescue sits in my menu bar and I always know what's running.",
  },
  {
    name: 'Diana Cho',
    company: 'PythonLabs',
    body: "I used to have port conflicts daily. Since installing Rescue, I haven't had a single one.",
  },
  {
    name: 'Ethan Jung',
    company: 'RustForge',
    body: 'The framework detection is surprisingly accurate. It correctly identifies my Axum and Actix servers.',
  },
  {
    name: 'Fiona Yoon',
    company: 'ReactHouse',
    body: 'Such a simple concept but incredibly useful. Every developer on my team now uses Rescue.',
  },
  {
    name: 'George Shin',
    company: 'GoLabs',
    body: "Lightweight, fast, and it just works. The auto-start feature means I never forget to run it.",
  },
  {
    name: 'Hannah Oh',
    company: 'DockerCo',
    body: 'Shows my Docker containers right alongside native processes. Absolutely love it.',
  },
  {
    name: 'Ian Kwon',
    company: 'FullstackIO',
    body: "I recommended Rescue to my whole team. It's now part of our standard macOS setup.",
  },
]

function InitialAvatar({ name }: { readonly name: string }) {
  const initials = name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)

  const colors = [
    'bg-orange-500',
    'bg-blue-500',
    'bg-green-500',
    'bg-purple-500',
    'bg-red-500',
    'bg-yellow-500',
    'bg-pink-500',
    'bg-teal-500',
    'bg-indigo-500',
  ]
  const colorIndex = name.charCodeAt(0) % colors.length

  return (
    <div
      className={`flex h-8 w-8 items-center justify-center rounded-full text-xs font-bold text-white ${colors[colorIndex]}`}
    >
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
    <section className="px-4 py-24 md:py-32">
      <div className="mx-auto max-w-6xl">
        <BlurFade delay={0} inView>
          <div className="mb-12 flex items-center justify-between">
            <div>
              <h2 className="text-3xl font-bold tracking-tight text-[#fafafa] sm:text-4xl">
                Testimonials
              </h2>
              <p className="mt-2 text-[#a1a1aa]">
                What developers are saying about Rescue.
              </p>
            </div>
            <a
              href="https://github.com/pointnemo/rescue"
              target="_blank"
              rel="noopener noreferrer"
              className="hidden sm:inline-flex items-center gap-1.5 rounded-lg border border-white/10 px-4 py-2 text-sm text-[#a1a1aa] hover:border-white/20 hover:text-[#fafafa] transition-colors"
            >
              See more
            </a>
          </div>
        </BlurFade>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {columns.map((col, ci) =>
            col.map((t, ti) => (
              <BlurFade key={t.name} delay={0.05 * (ci * 3 + ti)} inView>
                <div className="rounded-xl border border-white/10 bg-[#18181b] p-5 hover:border-white/20 transition-colors duration-200">
                  <div className="flex items-center gap-3 mb-3">
                    <InitialAvatar name={t.name} />
                    <div>
                      <div className="text-sm font-medium text-[#fafafa]">{t.name}</div>
                      <div className="text-xs text-[#a1a1aa]">{t.company}</div>
                    </div>
                  </div>
                  <p className="text-sm text-[#a1a1aa] leading-relaxed">{t.body}</p>
                </div>
              </BlurFade>
            )),
          )}
        </div>
      </div>
    </section>
  )
}
