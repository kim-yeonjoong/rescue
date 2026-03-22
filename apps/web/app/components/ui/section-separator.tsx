interface SectionSeparatorProps {
  readonly label: string
}

export function SectionSeparator({ label }: SectionSeparatorProps) {
  return (
    <div className="section-separator-bg border-y border-white/10 py-3 text-center">
      <span className="text-xs font-medium tracking-[0.2em] text-white/30 uppercase">
        {label}
      </span>
    </div>
  )
}
