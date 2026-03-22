import { createFileRoute } from '@tanstack/react-router'

import Features from '@/components/sections/features'
import Footer from '@/components/sections/footer'
import FrameworksMarquee from '@/components/sections/frameworks-marquee'
import Hero from '@/components/sections/hero'
import Install from '@/components/sections/install'
import Navbar from '@/components/sections/navbar'
import Screenshots from '@/components/sections/screenshots'

export const Route = createFileRoute('/')({
  component: Home,
})

function Home() {
  return (
    <main className="min-h-screen bg-[#0a1628] overflow-x-hidden">
      <Navbar />
      <Hero />
      <Features />
      <FrameworksMarquee />
      <Screenshots />
      <Install />
      <Footer />
    </main>
  )
}
