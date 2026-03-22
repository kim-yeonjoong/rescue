import { BlurFade } from '@/components/magicui/blur-fade'

const FEATURES = [
  {
    title: 'Port Scanning',
    description: 'Automatically scan all active ports and identify which processes are listening.',
    icon: (
      <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 111 11a6 6 0 0116 0z" />
      </svg>
    ),
  },
  {
    title: 'Framework Detection',
    description: 'Intelligently identifies Node.js, Python, Ruby, Go, Docker and 30+ more frameworks.',
    icon: (
      <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9.75 3.104v5.714a2.25 2.25 0 01-.659 1.591L5 14.5M9.75 3.104c-.251.023-.501.05-.75.082m.75-.082a24.301 24.301 0 014.5 0m0 0v5.714c0 .597.237 1.17.659 1.591L19.8 15.3M14.25 3.104c.251.023.501.05.75.082M19.8 15.3l-1.57.393A9.065 9.065 0 0112 15a9.065 9.065 0 00-6.23-.693L5 14.5m14.8.8l1.402 1.402c1.232 1.232.65 3.318-1.067 3.611" />
      </svg>
    ),
  },
  {
    title: 'Docker Support',
    description: 'Shows Docker containers right alongside native processes in a unified view.',
    icon: (
      <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M21 7.5l-9-5.25L3 7.5m18 0l-9 5.25m9-5.25v9l-9 5.25M3 7.5l9 5.25M3 7.5v9l9 5.25m0-9v9" />
      </svg>
    ),
  },
  {
    title: 'Portless Processes',
    description: 'Detects background services that don\'t expose ports, like build watchers and daemons.',
    icon: (
      <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
      </svg>
    ),
  },
  {
    title: 'Process Control',
    description: 'Kill any process instantly with one click from your menu bar. No more terminal hunting.',
    icon: (
      <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z" />
      </svg>
    ),
  },
  {
    title: 'Spotlight Search',
    description: 'Quickly search and filter processes by name, port, or framework from anywhere.',
    icon: (
      <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M9.568 3H5.25A2.25 2.25 0 003 5.25v4.318c0 .597.237 1.17.659 1.591l9.581 9.581c.699.699 1.78.872 2.607.33a18.095 18.095 0 005.223-5.223c.542-.827.369-1.908-.33-2.607L11.16 3.66A2.25 2.25 0 009.568 3z" />
        <path strokeLinecap="round" strokeLinejoin="round" d="M6 6h.008v.008H6V6z" />
      </svg>
    ),
  },
]

export default function Features() {
  return (
    <section>
      <div className="grid grid-cols-1 divide-y divide-white/10 border-t border-white/10 sm:grid-cols-2 sm:divide-y-0 lg:grid-cols-3">
          {FEATURES.map((feature, i) => (
            <BlurFade key={feature.title} delay={0.05 * i} inView>
              <div className={`flex flex-col p-8 ${i < 3 ? 'lg:border-b lg:border-white/10' : ''} ${i % 3 === 2 ? '' : 'sm:border-r sm:border-white/10'}`}>
                {/* Icon container */}
                <div className="mb-5 flex h-12 w-12 items-center justify-center rounded-xl border border-violet-500/30 bg-violet-500/10 text-violet-400">
                  {feature.icon}
                </div>
                <h3 className="mb-2 text-sm font-semibold text-white">{feature.title}</h3>
                <p className="flex-1 text-xs text-white/50 leading-relaxed">{feature.description}</p>
                <div className="mt-4">
                  <span className="text-xs text-violet-400 hover:text-violet-300 cursor-pointer transition-colors">
                    Learn more &gt;
                  </span>
                </div>
              </div>
            </BlurFade>
          ))}
        </div>
    </section>
  )
}
