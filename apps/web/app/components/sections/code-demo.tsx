'use client'

import { useState } from 'react'

import { BlurFade } from '@/components/magicui/blur-fade'
import { cn } from '@/lib/utils'

const TABS = [
  {
    title: 'Install via Homebrew',
    description: 'Get started with a single command.',
    code: `brew tap pointnemo/rescue
brew install rescue

# or download directly from GitHub
open https://github.com/pointnemo/rescue/releases/latest`,
  },
  {
    title: 'Scan Running Processes',
    description: 'Instantly find all dev servers on your ports.',
    code: `# Rescue automatically scans:
# • Port 3000 → Next.js (node)
# • Port 8080 → Python HTTP server
# • Port 5432 → PostgreSQL
# • Port 6379 → Redis
# • Port 9000 → Vite dev server`,
  },
  {
    title: 'Kill a Process',
    description: 'One click to kill any forgotten process.',
    code: `# Before Rescue:
lsof -ti:3000 | xargs kill -9

# With Rescue:
# Click the process in menu bar
# Press ⌘K to kill instantly`,
  },
  {
    title: 'Auto-start at Login',
    description: 'Rescue starts automatically with your Mac.',
    code: `# Rescue preferences:
# ✓ Launch at login
# ✓ Show in menu bar
# ✓ Notify on new processes
# ✓ Auto-scan interval: 5s`,
  },
]

interface CodeBlockProps {
  readonly tab: { title: string; code: string }
}

function CodeBlock({ tab }: CodeBlockProps) {
  return (
    <div className="flex-1 rounded-xl border border-white/10 bg-[#09090b] overflow-hidden">
      <div className="flex items-center gap-1.5 border-b border-white/10 px-4 py-3">
        <div className="h-3 w-3 rounded-full bg-[#ff5f57]" />
        <div className="h-3 w-3 rounded-full bg-[#febc2e]" />
        <div className="h-3 w-3 rounded-full bg-[#28c840]" />
        <span className="ml-3 text-xs text-[#a1a1aa]">{tab.title}</span>
      </div>
      <pre className="overflow-x-auto p-6">
        <code className="font-mono text-sm text-[#a1a1aa] whitespace-pre leading-relaxed">
          {tab.code}
        </code>
      </pre>
    </div>
  )
}

export default function CodeDemo() {
  const [selectedTab, setSelectedTab] = useState(0)

  return (
    <section className="px-4 py-24 md:py-32">
      <div className="mx-auto max-w-6xl">
        <BlurFade delay={0} inView>
          <div className="mb-12 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-[#fafafa] sm:text-4xl">
              Simple to use
            </h2>
            <p className="mt-4 text-[#a1a1aa]">
              Get up and running in seconds.
            </p>
          </div>
        </BlurFade>

        <BlurFade delay={0.1} inView>
          <div className="flex flex-col gap-6 lg:flex-row lg:gap-8">
            {/* Tab list */}
            <div className="flex flex-col gap-2 lg:w-72 lg:shrink-0">
              {TABS.map((tab, i) => (
                <button
                  key={tab.title}
                  onClick={() => setSelectedTab(i)}
                  className={cn(
                    'rounded-xl border px-4 py-3 text-left transition-all duration-200',
                    selectedTab === i
                      ? 'border-[#f97316]/50 bg-[#f97316]/10 text-[#fafafa]'
                      : 'border-white/10 bg-[#18181b] text-[#a1a1aa] hover:border-white/20 hover:text-[#fafafa]',
                  )}
                >
                  <div className="text-sm font-medium">{tab.title}</div>
                  <div className="mt-0.5 text-xs opacity-70">{tab.description}</div>
                </button>
              ))}
            </div>

            {/* Code block */}
            <CodeBlock tab={TABS[selectedTab] ?? TABS[0]!} />
          </div>
        </BlurFade>
      </div>
    </section>
  )
}
