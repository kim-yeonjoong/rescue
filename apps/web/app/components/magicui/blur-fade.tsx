import { motion, useInView, type Variants } from 'framer-motion'
import { useRef } from 'react'

interface BlurFadeProps {
  readonly children: React.ReactNode
  readonly className?: string
  readonly variant?: Variants
  readonly duration?: number
  readonly delay?: number
  readonly yOffset?: number
  readonly inView?: boolean
  readonly inViewMargin?: string
  readonly blur?: string
}

export function BlurFade({
  children,
  className,
  variant,
  duration = 0.4,
  delay = 0,
  yOffset = 6,
  inView = false,
  inViewMargin = '-50px',
  blur = '6px',
}: BlurFadeProps) {
  const ref = useRef(null)
  const inViewResult = useInView(ref, {
    once: true,
    margin: inViewMargin as Parameters<typeof useInView>[1]['margin'],
  })
  const isVisible = !inView || inViewResult

  const defaultVariants: Variants = {
    hidden: { y: yOffset, opacity: 0, filter: `blur(${blur})` },
    visible: { y: 0, opacity: 1, filter: 'blur(0px)' },
  }

  const combinedVariants = variant || defaultVariants

  return (
    <motion.div
      ref={ref}
      initial="hidden"
      animate={isVisible ? 'visible' : 'hidden'}
      variants={combinedVariants}
      transition={{ delay: 0.04 + delay, duration, ease: 'easeOut' }}
      className={className}
    >
      {children}
    </motion.div>
  )
}
