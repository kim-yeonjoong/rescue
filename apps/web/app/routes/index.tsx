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

export const Route = createFileRoute('/')({
  component: Home,
})

function Home() {
  return (
    <main className="min-h-screen bg-[#09090b] overflow-x-hidden">
      <Navbar />
      <Hero />
      <Logos />
      <CodeDemo />
      <UseCases />
      <Features />
      <Stats />
      <Testimonials />
      <Pricing />
      <Community />
      <Blog />
      <Cta />
      <Footer />
    </main>
  )
}
