'use client'

import { useState } from 'react'

import { BlurFade } from '@/components/magicui/blur-fade'
import { cn } from '@/lib/utils'

const TABS = [
  {
    title: 'Install',
    description: 'Get started in seconds.',
    lines: [
      { tokens: [{ text: '# Install via Homebrew', color: 'text-white/30' }] },
      { tokens: [{ text: 'brew tap ', color: 'text-white/60' }, { text: 'pointnemo/rescue', color: 'text-green-400' }] },
      { tokens: [{ text: 'brew install ', color: 'text-white/60' }, { text: 'rescue', color: 'text-green-400' }] },
      { tokens: [] },
      { tokens: [{ text: '# or download directly', color: 'text-white/30' }] },
      { tokens: [{ text: 'open ', color: 'text-white/60' }, { text: 'https://github.com/pointnemo/rescue', color: 'text-blue-400' }] },
    ],
  },
  {
    title: 'Scan',
    description: 'Find all running dev servers.',
    lines: [
      { tokens: [{ text: '# Rescue automatically scans:', color: 'text-white/30' }] },
      { tokens: [{ text: ':3000 ', color: 'text-violet-400' }, { text: '→ ', color: 'text-white/30' }, { text: 'Next.js', color: 'text-white' }, { text: ' (node)', color: 'text-white/40' }] },
      { tokens: [{ text: ':8080 ', color: 'text-violet-400' }, { text: '→ ', color: 'text-white/30' }, { text: 'Python HTTP', color: 'text-blue-400' }, { text: ' server', color: 'text-white/40' }] },
      { tokens: [{ text: ':5432 ', color: 'text-violet-400' }, { text: '→ ', color: 'text-white/30' }, { text: 'PostgreSQL', color: 'text-green-400' }] },
      { tokens: [{ text: ':6379 ', color: 'text-violet-400' }, { text: '→ ', color: 'text-white/30' }, { text: 'Redis', color: 'text-red-400' }] },
      { tokens: [{ text: ':9000 ', color: 'text-violet-400' }, { text: '→ ', color: 'text-white/30' }, { text: 'Vite', color: 'text-yellow-400' }, { text: ' dev server', color: 'text-white/40' }] },
    ],
  },
  {
    title: 'Kill',
    description: 'One click to stop any process.',
    lines: [
      { tokens: [{ text: '# Before Rescue:', color: 'text-white/30' }] },
      { tokens: [{ text: 'lsof ', color: 'text-white/60' }, { text: '-ti:3000', color: 'text-orange-400' }, { text: ' | xargs ', color: 'text-white/40' }, { text: 'kill ', color: 'text-red-400' }, { text: '-9', color: 'text-orange-400' }] },
      { tokens: [] },
      { tokens: [{ text: '# With Rescue:', color: 'text-white/30' }] },
      { tokens: [{ text: '# Click process in menu bar', color: 'text-white/30' }] },
      { tokens: [{ text: '# Press ', color: 'text-white/30' }, { text: '⌘K', color: 'text-violet-400' }, { text: ' to kill instantly', color: 'text-white/30' }] },
    ],
  },
  {
    title: 'Config',
    description: 'Rescue starts with your Mac.',
    lines: [
      { tokens: [{ text: '# Rescue preferences:', color: 'text-white/30' }] },
      { tokens: [{ text: '✓ ', color: 'text-green-400' }, { text: 'Launch at login', color: 'text-white/70' }] },
      { tokens: [{ text: '✓ ', color: 'text-green-400' }, { text: 'Show in menu bar', color: 'text-white/70' }] },
      { tokens: [{ text: '✓ ', color: 'text-green-400' }, { text: 'Notify on new processes', color: 'text-white/70' }] },
      { tokens: [{ text: '✓ ', color: 'text-green-400' }, { text: 'Auto-scan interval: ', color: 'text-white/70' }, { text: '5s', color: 'text-violet-400' }] },
    ],
  },
]

export default function CodeDemo() {
  const [selectedTab, setSelectedTab] = useState(0)
  const currentTab = TABS[selectedTab] ?? TABS[0]!

  return (
    <section className="border-t border-white/10 px-10 py-16">
      <BlurFade delay={0} inView>
        <div className="mb-10 text-center">
          <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
            Simple to use
          </h2>
          <p className="mt-3 text-sm text-white/50">
            Get up and running in seconds.
          </p>
        </div>
      </BlurFade>

      <BlurFade delay={0.1} inView>
        <div className="flex flex-col gap-4 lg:flex-row lg:gap-6">
          {/* Tab list */}
          <div className="flex flex-col gap-1 lg:w-56 lg:shrink-0">
            {TABS.map((tab, i) => (
              <button
                key={tab.title}
                onClick={() => setSelectedTab(i)}
                className={cn(
                  'rounded-lg border px-4 py-3 text-left transition-all duration-200',
                  selectedTab === i
                    ? 'border-violet-500/50 bg-violet-500/10 text-white'
                    : 'border-white/10 bg-[#111111] text-white/50 hover:border-white/20 hover:text-white',
                )}
              >
                <div className="text-sm font-medium">{tab.title}</div>
                <div className="mt-0.5 text-xs opacity-60">{tab.description}</div>
              </button>
            ))}
          </div>

          {/* Code block */}
          <div className="flex-1 rounded-lg border border-white/10 bg-[#0a0a0a] overflow-hidden">
            <div className="flex items-center gap-1.5 border-b border-white/10 px-4 py-3">
              <div className="h-2.5 w-2.5 rounded-full bg-[#ff5f57]" />
              <div className="h-2.5 w-2.5 rounded-full bg-[#febc2e]" />
              <div className="h-2.5 w-2.5 rounded-full bg-[#28c840]" />
              <span className="ml-3 text-xs text-white/30">{currentTab.title}</span>
            </div>
            <pre className="overflow-x-auto p-6">
              <code className="font-mono text-sm leading-relaxed">
                {currentTab.lines.map((line, li) => (
                  <div key={line.tokens.map((t) => t.text).join('') || `empty-${li}`}>
                    {line.tokens.length === 0 ? (
                      <span>&nbsp;</span>
                    ) : (
                      line.tokens.map((token) => (
                        <span key={`${token.color}-${token.text}`} className={token.color}>{token.text}</span>
                      ))
                    )}
                  </div>
                ))}
              </code>
            </pre>
          </div>
        </div>
      </BlurFade>
    </section>
  )
}
