import { BlurFade } from '@/components/magicui/blur-fade'

const POSTS = [
  {
    title: 'Introducing Rescue',
    date: 'March 1, 2025',
    summary:
      'Meet Rescue, the macOS menu bar app that helps you find and manage forgotten dev processes.',
    gradient: 'from-orange-500/20 to-red-500/20',
  },
  {
    title: 'Why I Built Rescue',
    date: 'February 15, 2025',
    summary:
      'I was tired of forgotten dev servers hogging ports. So I built a tool to fix that.',
    gradient: 'from-blue-500/20 to-purple-500/20',
  },
  {
    title: 'How Rescue Detects Frameworks',
    date: 'January 30, 2025',
    summary:
      'A deep dive into how Rescue identifies Node.js, Python, Ruby, and other dev servers.',
    gradient: 'from-green-500/20 to-teal-500/20',
  },
]

export default function Blog() {
  return (
    <section className="px-4 py-24 md:py-32">
      <div className="mx-auto max-w-6xl">
        <BlurFade delay={0} inView>
          <div className="mb-12 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-[#fafafa] sm:text-4xl">
              Blog
            </h2>
            <p className="mt-4 text-[#a1a1aa]">
              Updates and stories from the Rescue team.
            </p>
          </div>
        </BlurFade>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {POSTS.map((post, i) => (
            <BlurFade key={post.title} delay={0.1 * i} inView>
              <div className="rounded-xl border border-white/10 bg-[#18181b] overflow-hidden hover:border-white/20 transition-colors duration-200 cursor-pointer h-full flex flex-col">
                {/* Image placeholder */}
                <div className={`h-40 bg-gradient-to-br ${post.gradient}`} />
                <div className="p-5 flex-1 flex flex-col">
                  <time className="text-xs text-[#a1a1aa]">{post.date}</time>
                  <h3 className="mt-2 text-base font-semibold text-[#fafafa] leading-snug">
                    {post.title}
                  </h3>
                  <p className="mt-2 text-sm text-[#a1a1aa] leading-relaxed flex-1">
                    {post.summary}
                  </p>
                  <div className="mt-4">
                    <span className="text-xs text-[#f97316] hover:underline">Read more &gt;</span>
                  </div>
                </div>
              </div>
            </BlurFade>
          ))}
        </div>
      </div>
    </section>
  )
}
