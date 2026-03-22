'use client'

import { useState } from 'react'

import { BlurFade } from '@/components/magicui/blur-fade'
import { cn } from '@/lib/utils'

const RELEASES_URL = 'https://github.com/pointnemo/rescue/releases/latest'
const SPONSOR_URL = 'https://github.com/sponsors/pointnemo'
const CONTACT_URL = 'mailto:hello@pointnemo.com'

type BillingPeriod = 'yearly' | 'monthly'

function CheckIcon() {
  return (
    <svg className="h-4 w-4 text-green-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
    </svg>
  )
}

export default function Pricing() {
  const [billing, setBilling] = useState<BillingPeriod>('yearly')

  return (
    <section>
      <div className="border-t border-white/10 px-10 py-16">
        <BlurFade delay={0} inView>
          <div className="mb-10 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
              Simple pricing for everyone.
            </h2>
            <p className="mt-3 text-sm text-white/60">
              Choose an <strong className="text-white font-semibold">affordable plan</strong> that works best for you.
            </p>

            {/* Toggle */}
            <div className="mt-6 inline-flex items-center rounded-full border border-white/10 bg-[#111111] p-1 text-sm">
              <button
                onClick={() => setBilling('yearly')}
                className={cn(
                  'rounded-full px-4 py-1.5 font-medium transition-all duration-200',
                  billing === 'yearly'
                    ? 'bg-white text-black'
                    : 'text-white/50 hover:text-white',
                )}
              >
                Yearly <span className="ml-1 text-xs text-green-400 font-normal">Save 25%</span>
              </button>
              <button
                onClick={() => setBilling('monthly')}
                className={cn(
                  'rounded-full px-4 py-1.5 font-medium transition-all duration-200',
                  billing === 'monthly'
                    ? 'bg-white text-black'
                    : 'text-white/50 hover:text-white',
                )}
              >
                Monthly
              </button>
            </div>
          </div>
        </BlurFade>

        {/* Plans */}
        <div className="grid grid-cols-1 divide-y divide-white/10 border border-white/10 sm:grid-cols-3 sm:divide-x sm:divide-y-0">
          {/* Basic / Free */}
          <BlurFade delay={0.1} inView>
            <div className="flex flex-col p-8">
              <h3 className="text-sm font-semibold text-white">Basic</h3>
              <div className="mt-4 flex items-end gap-1">
                <span className="text-4xl font-bold text-white">$0</span>
                <span className="mb-1 text-sm text-white/40">/ forever</span>
              </div>
              <p className="mt-2 text-xs text-white/50">Perfect for individual developers.</p>

              <ul className="mt-8 flex-1 space-y-3">
                {[
                  'All features included',
                  'Menu bar integration',
                  'Auto-start at login',
                  'Community support',
                ].map((item) => (
                  <li key={item} className="flex items-center gap-2.5 text-xs text-white/60">
                    <CheckIcon />
                    {item}
                  </li>
                ))}
              </ul>

              <a href={RELEASES_URL} target="_blank" rel="noopener noreferrer" className="mt-8 block">
                <button className="w-full rounded-lg border border-white/20 bg-transparent py-2.5 text-sm font-medium text-white hover:bg-white/5 transition-colors">
                  Download for Free
                </button>
              </a>
            </div>
          </BlurFade>

          {/* Pro / Sponsor — Most Popular */}
          <BlurFade delay={0.15} inView>
            <div className="relative flex flex-col p-8">
              {/* Most Popular badge */}
              <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                <span className="rounded-full bg-violet-500/80 px-3 py-1 text-xs font-semibold text-white">
                  Most Popular
                </span>
              </div>

              <h3 className="text-sm font-semibold text-white">Pro</h3>
              <div className="mt-4 flex items-end gap-1">
                <span className="text-4xl font-bold text-white">
                  {billing === 'yearly' ? '$4' : '$5'}
                </span>
                <span className="mb-1 text-sm text-white/40">/ month</span>
              </div>
              <p className="mt-2 text-xs text-white/50">Support ongoing development.</p>

              <ul className="mt-8 flex-1 space-y-3">
                {[
                  'All Basic features',
                  'Early access to new features',
                  'Priority issue responses',
                  'Sponsor badge on GitHub',
                  'Direct feature requests',
                  'Discord community access',
                ].map((item) => (
                  <li key={item} className="flex items-center gap-2.5 text-xs text-white/60">
                    <CheckIcon />
                    {item}
                  </li>
                ))}
              </ul>

              <a href={SPONSOR_URL} target="_blank" rel="noopener noreferrer" className="mt-8 block">
                <button className="w-full rounded-lg bg-violet-500 py-2.5 text-sm font-medium text-white hover:bg-violet-600 transition-colors">
                  Become a Sponsor
                </button>
              </a>
            </div>
          </BlurFade>

          {/* Enterprise */}
          <BlurFade delay={0.2} inView>
            <div className="flex flex-col p-8">
              <h3 className="text-sm font-semibold text-white">Enterprise</h3>
              <div className="mt-4 flex items-end gap-1">
                <span className="text-4xl font-bold text-white">Custom</span>
              </div>
              <p className="mt-2 text-xs text-white/50">For teams and organizations.</p>

              <ul className="mt-8 flex-1 space-y-3">
                {[
                  'Unlimited installations',
                  'Custom integrations',
                  'Dedicated support channel',
                  'SLA guarantee',
                  'Invoice billing',
                  'Priority roadmap input',
                ].map((item) => (
                  <li key={item} className="flex items-center gap-2.5 text-xs text-white/60">
                    <CheckIcon />
                    {item}
                  </li>
                ))}
              </ul>

              <a href={CONTACT_URL} className="mt-8 block">
                <button className="w-full rounded-lg border border-white/20 bg-transparent py-2.5 text-sm font-medium text-white hover:bg-white/5 transition-colors">
                  Contact Us
                </button>
              </a>
            </div>
          </BlurFade>
        </div>
      </div>
    </section>
  )
}
