import { BlurFade } from '@/components/magicui/blur-fade'

const GITHUB_URL = 'https://github.com/pointnemo/rescue'

const CONTRIBUTORS = [
  { initials: 'AK', color: 'bg-orange-500' },
  { initials: 'BL', color: 'bg-blue-500' },
  { initials: 'CP', color: 'bg-green-500' },
  { initials: 'DC', color: 'bg-purple-500' },
  { initials: 'EJ', color: 'bg-red-500' },
]

export default function Community() {
  return (
    <section>
      <div className="border-t border-white/10">
        <BlurFade delay={0} inView>
          <div
            className="relative overflow-hidden px-10 py-20 text-center"
            style={{
              backgroundImage:
                'radial-gradient(circle at 50% 50%, rgba(139,92,246,0.06) 0%, transparent 60%)',
            }}
          >
            {/* Concentric arc decorations */}
            <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
              {[180, 140, 100].map((size) => (
                <div
                  key={size}
                  className="absolute rounded-full border border-white/[0.04]"
                  style={{ width: `${size}%`, height: `${size}%` }}
                />
              ))}
            </div>

            <div className="relative">
              <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl mb-4">
                Built with the community
              </h2>
              <p className="mx-auto max-w-md text-sm text-white/50 leading-relaxed mb-8">
                We're grateful for the amazing open-source community that helps make Rescue better every day.
              </p>

              {/* Overlapping avatars */}
              <div className="mb-8 flex items-center justify-center">
                <div className="flex items-center -space-x-3">
                  {CONTRIBUTORS.map((c) => (
                    <div
                      key={c.initials}
                      className={`flex h-10 w-10 items-center justify-center rounded-full border-2 border-[#0a0a0a] text-xs font-bold text-white ${c.color}`}
                    >
                      {c.initials}
                    </div>
                  ))}
                </div>
              </div>

              <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer">
                <button className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-[#111111] px-5 py-2.5 text-sm font-medium text-white hover:border-white/20 hover:bg-[#1a1a1a] transition-all duration-200">
                  <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                    <path
                      fillRule="evenodd"
                      d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                      clipRule="evenodd"
                    />
                  </svg>
                  Become a contributor
                </button>
              </a>
            </div>
          </div>
        </BlurFade>
      </div>
    </section>
  )
}
