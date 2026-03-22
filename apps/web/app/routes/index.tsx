import { createFileRoute } from '@tanstack/react-router'

import Blog from '@/components/sections/blog'
import CodeDemo from '@/components/sections/code-demo'
import Community from '@/components/sections/community'
import Cta from '@/components/sections/cta'
import Features from '@/components/sections/features'
import Footer from '@/components/sections/footer'
import Hero from '@/components/sections/hero'
import Logos from '@/components/sections/logos'
import Navbar from '@/components/sections/navbar'
import Pricing from '@/components/sections/pricing'
import Stats from '@/components/sections/stats'
import Testimonials from '@/components/sections/testimonials'
import UseCases from '@/components/sections/use-cases'
import { SectionSeparator } from '@/components/ui/section-separator'

export const Route = createFileRoute('/')({
  component: Home,
})

function Home() {
  return (
    <main className="min-h-screen bg-[#0a0a0a] overflow-x-hidden">
      <Navbar />
      {/* Single continuous bordered column */}
      <div className="mx-auto max-w-[960px] border-x border-white/10">
        <Hero />
        <Logos />
        <CodeDemo />
        <SectionSeparator label="Use Cases" />
        <UseCases />
        <SectionSeparator label="Features" />
        <Features />
        <SectionSeparator label="Statistics" />
        <Stats />
        <SectionSeparator label="Testimonials" />
        <Testimonials />
        <SectionSeparator label="Pricing" />
        <Pricing />
        <SectionSeparator label="Community" />
        <Community />
        <SectionSeparator label="Blog" />
        <Blog />
        <Cta />
      </div>
      <Footer />
    </main>
  )
}
