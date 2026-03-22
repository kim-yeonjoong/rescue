import { Button } from '@/components/ui/button'

const RELEASES_URL = 'https://github.com/pointnemo/rescue/releases/latest'

export default function Navbar() {
  return (
    <header className="sticky top-0 z-50 w-full border-b border-white/10 bg-[#09090b]/80 backdrop-blur-md">
      <div className="mx-auto flex h-14 max-w-6xl items-center justify-between px-4 md:px-6">
        <a href="/" className="flex items-center gap-2.5">
          <img src="/logo.svg" alt="Rescue" className="h-7 w-7" />
          <span className="text-base font-semibold text-[#fafafa]">Rescue</span>
        </a>

        <nav className="flex items-center gap-2">
          <a href={RELEASES_URL} target="_blank" rel="noopener noreferrer">
            <Button size="sm">Download</Button>
          </a>
        </nav>
      </div>
    </header>
  )
}
