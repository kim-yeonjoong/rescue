const GITHUB_URL = 'https://github.com/pointnemo/rescue'
const RELEASES_URL = 'https://github.com/pointnemo/rescue/releases'
const LICENSE_URL = 'https://github.com/pointnemo/rescue/blob/main/LICENSE'

export default function Footer() {
  return (
    <footer className="border-t border-white/8 px-4 py-12">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-6 text-center sm:flex-row sm:justify-between sm:text-left">
        <div className="flex items-center gap-2.5">
          <img src="/logo.svg" alt="Rescue" className="h-6 w-6" />
          <div>
            <p className="text-sm font-semibold text-[#f1f5f9]">Rescue</p>
            <p className="text-xs text-[#94a3b8]">Find what you forgot you started</p>
          </div>
        </div>

        <nav className="flex items-center gap-6">
          <a
            href={GITHUB_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm text-[#94a3b8] transition-colors hover:text-[#f1f5f9]"
          >
            GitHub
          </a>
          <a
            href={RELEASES_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm text-[#94a3b8] transition-colors hover:text-[#f1f5f9]"
          >
            Releases
          </a>
          <a
            href={LICENSE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm text-[#94a3b8] transition-colors hover:text-[#f1f5f9]"
          >
            License
          </a>
        </nav>
      </div>
    </footer>
  )
}
