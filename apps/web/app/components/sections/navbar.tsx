const RELEASES_URL = 'https://github.com/pointnemo/rescue/releases/latest'

export default function Navbar() {
  return (
    <header className="sticky top-0 z-50 w-full bg-[#0a0a0a]/90 backdrop-blur-sm">
      <div className="mx-auto flex h-14 max-w-[960px] items-center justify-between border-x border-white/10 px-6">
        <a href="/" className="flex items-center gap-2">
          <svg
            width="20"
            height="20"
            viewBox="0 0 20 20"
            fill="none"
            className="text-white"
            aria-hidden="true"
          >
            <text x="0" y="15" fontSize="14" fontFamily="monospace" fill="currentColor">&gt;_</text>
          </svg>
          <span className="text-sm font-semibold text-white">Rescue</span>
        </a>

        <nav>
          <a href={RELEASES_URL} target="_blank" rel="noopener noreferrer">
            <button className="rounded-full bg-white px-4 py-1.5 text-sm font-medium text-black hover:bg-white/90 transition-colors">
              Get Started
            </button>
          </a>
        </nav>
      </div>
    </header>
  )
}
