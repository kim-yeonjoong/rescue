import { createFileRoute } from '@tanstack/react-router'
import Navbar from '@/components/sections/navbar'
import Hero from '@/components/sections/hero'
import Features from '@/components/sections/features'
import FrameworksMarquee from '@/components/sections/frameworks-marquee'
import Screenshots from '@/components/sections/screenshots'
import Install from '@/components/sections/install'
import Footer from '@/components/sections/footer'

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
