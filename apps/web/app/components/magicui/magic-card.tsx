import { useRef, useState } from 'react'
import { cn } from '@/lib/utils'

interface MagicCardProps {
  children: React.ReactNode
  className?: string
  gradientSize?: number
  gradientColor?: string
  gradientOpacity?: number
}

export function MagicCard({
  children,
  className,
  gradientSize = 200,
  gradientColor = '#f97316',
  gradientOpacity = 0.08,
}: MagicCardProps) {
  const cardRef = useRef<HTMLDivElement>(null)
  const [gradientPos, setGradientPos] = useState({ x: -100, y: -100 })

  function handleMouseMove(e: React.MouseEvent<HTMLDivElement>) {
    const rect = cardRef.current?.getBoundingClientRect()
    if (!rect) return
    setGradientPos({
      x: e.clientX - rect.left,
      y: e.clientY - rect.top,
    })
  }

  function handleMouseLeave() {
    setGradientPos({ x: -100, y: -100 })
  }

  return (
    <div
      ref={cardRef}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className={cn('relative overflow-hidden rounded-xl', className)}
      style={{
        background: `radial-gradient(${gradientSize}px circle at ${gradientPos.x}px ${gradientPos.y}px, ${gradientColor}${Math.round(gradientOpacity * 255).toString(16).padStart(2, '0')}, transparent 80%)`,
      }}
    >
      {children}
    </div>
  )
}
