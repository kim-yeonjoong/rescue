'use client'

import { useState } from 'react'

import { BlurFade } from '@/components/magicui/blur-fade'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

const RELEASES_URL = 'https://github.com/pointnemo/rescue/releases/latest'
const SPONSOR_URL = 'https://github.com/sponsors/pointnemo'
const CONTACT_URL = 'mailto:hello@pointnemo.com'

type BillingPeriod = 'sponsor' | 'one-time'

export default function Pricing() {
  const [billing, setBilling] = useState<BillingPeriod>('sponsor')

  return (
    <section className="px-4 py-24 md:py-32">
      <div className="mx-auto max-w-6xl">
        <BlurFade delay={0} inView>
          <div className="mb-12 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-[#fafafa] sm:text-4xl">
              Pricing
            </h2>
            <p className="mt-4 text-[#a1a1aa]">
              Free forever. Support development if you love it.
            </p>

            {/* Toggle */}
            <div className="mt-6 inline-flex items-center rounded-xl border border-white/10 bg-[#18181b] p-1">
              {(['sponsor', 'one-time'] as const).map((period) => (
                <button
                  key={period}
                  onClick={() => setBilling(period)}
                  className={cn(
                    'rounded-lg px-5 py-2 text-sm font-medium transition-all duration-200',
                    billing === period
                      ? 'bg-[#f97316] text-white shadow-sm'
                      : 'text-[#a1a1aa] hover:text-[#fafafa]',
                  )}
                >
                  {period === 'sponsor' ? 'Sponsor' : 'One-time'}
                </button>
              ))}
            </div>
          </div>
        </BlurFade>

        <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
          {/* Free */}
          <BlurFade delay={0.1} inView>
            <div className="rounded-xl border border-white/10 bg-[#18181b] p-6 h-full flex flex-col">
              <div className="mb-6">
                <h3 className="text-lg font-semibold text-[#fafafa]">Free</h3>
                <div className="mt-3 flex items-end gap-1">
                  <span className="text-4xl font-bold text-[#fafafa]">$0</span>
                  <span className="mb-1 text-sm text-[#a1a1aa]">/ forever</span>
                </div>
                <p className="mt-2 text-sm text-[#a1a1aa]">
                  Perfect for individual developers.
                </p>
              </div>
              <ul className="flex-1 space-y-3 mb-6">
                {[
                  'All features included',
                  'Menu bar integration',
                  'Auto-start at login',
                  'Community support',
                ].map((item) => (
                  <li key={item} className="flex items-center gap-2 text-sm text-[#a1a1aa]">
                    <span className="text-[#22c55e]">✓</span>
                    {item}
                  </li>
                ))}
              </ul>
              <a href={RELEASES_URL} target="_blank" rel="noopener noreferrer">
                <Button variant="outline" className="w-full">
                  Download for Free
                </Button>
              </a>
            </div>
          </BlurFade>

          {/* Sponsor */}
          <BlurFade delay={0.2} inView>
            <div className="rounded-xl border border-[#f97316]/50 bg-[#18181b] p-6 h-full flex flex-col relative">
              <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                <span className="rounded-full bg-[#f97316] px-3 py-1 text-xs font-semibold text-white">
                  ⭐ Most Popular
                </span>
              </div>
              <div className="mb-6">
                <h3 className="text-lg font-semibold text-[#fafafa]">Sponsor</h3>
                <div className="mt-3 flex items-end gap-1">
                  <span className="text-4xl font-bold text-[#fafafa]">$5</span>
                  <span className="mb-1 text-sm text-[#a1a1aa]">
                    / {billing === 'sponsor' ? 'month' : 'one-time'}
                  </span>
                </div>
                <p className="mt-2 text-sm text-[#a1a1aa]">
                  Support ongoing development.
                </p>
              </div>
              <ul className="flex-1 space-y-3 mb-6">
                {[
                  'All Free features',
                  'Early access to new features',
                  'Priority issue responses',
                  'Sponsor badge on GitHub',
                  'Direct feature requests',
                  'Discord access',
                ].map((item) => (
                  <li key={item} className="flex items-center gap-2 text-sm text-[#a1a1aa]">
                    <span className="text-[#22c55e]">✓</span>
                    {item}
                  </li>
                ))}
              </ul>
              <a href={SPONSOR_URL} target="_blank" rel="noopener noreferrer">
                <Button className="w-full">
                  Become a Sponsor
                </Button>
              </a>
            </div>
          </BlurFade>

          {/* Enterprise */}
          <BlurFade delay={0.3} inView>
            <div className="rounded-xl border border-white/10 bg-[#18181b] p-6 h-full flex flex-col">
              <div className="mb-6">
                <h3 className="text-lg font-semibold text-[#fafafa]">Enterprise</h3>
                <div className="mt-3 flex items-end gap-1">
                  <span className="text-4xl font-bold text-[#fafafa]">Custom</span>
                  <span className="mb-1 text-sm text-[#a1a1aa]">/ year</span>
                </div>
                <p className="mt-2 text-sm text-[#a1a1aa]">
                  For teams and organizations.
                </p>
              </div>
              <ul className="flex-1 space-y-3 mb-6">
                {[
                  'Unlimited installations',
                  'Custom integrations',
                  'Dedicated support',
                  'SLA guarantee',
                  'Invoice billing',
                  'Priority roadmap input',
                ].map((item) => (
                  <li key={item} className="flex items-center gap-2 text-sm text-[#a1a1aa]">
                    <span className="text-[#22c55e]">✓</span>
                    {item}
                  </li>
                ))}
              </ul>
              <a href={CONTACT_URL}>
                <Button variant="outline" className="w-full">
                  Contact Us
                </Button>
              </a>
            </div>
          </BlurFade>
        </div>
      </div>
    </section>
  )
}
